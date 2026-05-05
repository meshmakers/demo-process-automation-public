param(
    [string]$rtWellKnownName = "Anthropic",
    [string]$rtId = "aa0d15c00000000000a1c0a1"
)

$ErrorActionPreference = 'Stop'

# Imports an AiConfiguration runtime entity for the System.Communication
# CK model. Pipelines that include an AnthropicAiQuery@1 node resolve the
# API key by:
#   1. Carrying a System.Communication/Uses association to this entity, and
#   2. Setting `apiKeyConfigurationName: <RtWellKnownName>` on the node.
#
# Re-running this script with -r overwrites the existing entity, which is
# the supported way to rotate the key.
#
# Note: AiConfiguration also has AiModel/MaxTokens/Temperature CK attributes,
# but the AnthropicAiQuery@1 node does not currently read them — those come
# from the per-node config in the pipeline YAML (Model defaults to
# claude-sonnet-4-20250514). Only ApiKey (and McpServerUrl) are sourced from
# this entity, so the script doesn't write the unused attributes.

$secure = Read-Host "Enter Anthropic API key (input hidden)" -AsSecureString

# Cross-platform SecureString -> plaintext. Marshal.PtrToStringAuto misreads
# the UTF-16 BSTR as ANSI on macOS/Linux pwsh, truncating the result to the
# first character. NetworkCredential goes through .NET's own conversion and
# works the same everywhere.
$apiKey = [System.Net.NetworkCredential]::new("", $secure).Password

if ([string]::IsNullOrWhiteSpace($apiKey)) {
    Write-Error "API key is required."
    exit 1
}

# Sanity check: an obviously-too-short value almost certainly means a paste
# issue or a regression in the conversion above. Anthropic keys are >40 chars.
if ($apiKey.Length -lt 20) {
    Write-Error "API key looks truncated (length=$($apiKey.Length)). Aborting."
    exit 1
}

# Quote with single quotes for YAML to keep `sk-ant-...` opaque to the
# parser; reject keys that contain single quotes since we don't escape.
if ($apiKey.Contains("'")) {
    Write-Error "API key contains a single quote — refusing to embed in YAML."
    exit 1
}

# [System.IO.Path]::GetTempPath() resolves to the OS temp dir on Windows,
# macOS and Linux — $env:TEMP is only populated on Windows.
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("rt-ai-configuration-{0}.yaml" -f ([guid]::NewGuid().ToString("N")))

$yaml = @"
`$schema: https://schemas.meshmakers.cloud/runtime-model.schema.json
dependencies:
  - System.Communication-[3.0,4.0)
entities:
  - rtId: $rtId
    rtWellKnownName: $rtWellKnownName
    ckTypeId: System.Communication/AiConfiguration
    attributes:
      - id: System.Communication/ApiKey
        value: '$apiKey'
"@

Set-Content -LiteralPath $tmp -Value $yaml -Encoding UTF8

try {
    octo-cli -c ImportRt -f $tmp -w -r
    if ($LASTEXITCODE -ne 0) {
        throw "octo-cli ImportRt failed with exit code $LASTEXITCODE."
    }
}
finally {
    Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "==================================================================="
Write-Host " AiConfiguration imported."
Write-Host "   RtId               : $rtId"
Write-Host "   RtWellKnownName    : $rtWellKnownName"
Write-Host "   ApiKey length      : $($apiKey.Length) chars"
Write-Host ""
Write-Host " Pipelines that need AI must:"
Write-Host "   1. Carry a System.Communication/Uses association to RtId $rtId"
Write-Host "      (targetCkTypeId: System.Communication/AiConfiguration)"
Write-Host "   2. Set 'apiKeyConfigurationName: $rtWellKnownName' on every"
Write-Host "      AnthropicAiQuery@1 node."
Write-Host "==================================================================="
Write-Host ""
