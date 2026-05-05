param (
    [string]$tenantId = "meshtest",
    [string]$systemContextName = "local_octosystem"
)

$ErrorActionPreference = 'Stop'

# Create must run from a system-tenant context. Its auth claims stay
# valid regardless of which tenants come and go, and `Create` auto-
# provisions the current system user as admin of the new tenant.
#
# Service URLs for the new per-tenant context are inherited from the
# system context's saved settings rather than hardcoded. This keeps the
# script working across getting-started's docker setup (which uses the
# `octo-identity-services` hostname so the service certificate validates)
# and source-mode setups (which use plain `localhost`). Whatever the user
# already configured for `local_octosystem` is what we propagate.

$contextsFile = Join-Path $HOME ".octo-cli/contexts.json"
if (-not (Test-Path -LiteralPath $contextsFile)) {
    Write-Error "octo-cli contexts file not found at $contextsFile. Set up the '$systemContextName' context first (getting-started's om-login-local.ps1)."
    exit 1
}

$contexts = Get-Content -LiteralPath $contextsFile -Raw | ConvertFrom-Json
$sourceContext = $contexts.Contexts.$systemContextName
if (-not $sourceContext) {
    Write-Error "Context '$systemContextName' not found in $contextsFile. Set it up first (getting-started's om-login-local.ps1)."
    exit 1
}

$opts = $sourceContext.OctoToolOptions

# Required URLs - bail clearly if the source context is incomplete
foreach ($field in 'IdentityServiceUrl', 'AssetServiceUrl', 'BotServiceUrl', 'CommunicationServiceUrl') {
    if (-not $opts.$field) {
        Write-Error "Context '$systemContextName' is missing $field. Re-run getting-started's om-login-local.ps1."
        exit 1
    }
}

octo-cli -c UseContext -n $systemContextName

# Create the tenant (auto-provisions the current user)
octo-cli -c Create -tid $tenantId -db $tenantId

# Register the per-tenant context that om_delete_tenants.ps1 removes
# (and that a first-time user doesn't yet have).
$tenantContextName = "local_$tenantId"

# -rsu is optional - only pass it through when the source context has it set
$addContextArgs = @(
    '-c', 'AddContext',
    '-n', $tenantContextName,
    '-isu', $opts.IdentityServiceUrl,
    '-asu', $opts.AssetServiceUrl,
    '-bsu', $opts.BotServiceUrl,
    '-csu', $opts.CommunicationServiceUrl,
    '-tid', $tenantId
)
if ($opts.ReportingServiceUrl) {
    $addContextArgs += @('-rsu', $opts.ReportingServiceUrl)
}
octo-cli @addContextArgs

# Switch to the new tenant context so subsequent tenant-scoped
# commands (EnableCommunication, ImportCk, ImportRt ...) operate
# on the new tenant.
octo-cli -c UseContext -n $tenantContextName

Write-Host ""
Write-Host "==================================================================="
Write-Host " Tenant '$tenantId' created and provisioned."
Write-Host " Active context switched to '$tenantContextName'."
Write-Host " URLs inherited from '$systemContextName':"
Write-Host "   Identity      : $($opts.IdentityServiceUrl)"
Write-Host "   Asset         : $($opts.AssetServiceUrl)"
Write-Host "   Bot           : $($opts.BotServiceUrl)"
Write-Host "   Communication : $($opts.CommunicationServiceUrl)"
if ($opts.ReportingServiceUrl) {
    Write-Host "   Reporting     : $($opts.ReportingServiceUrl)"
}
Write-Host ""
Write-Host " NEXT STEP (required, interactive):"
Write-Host "   octo-cli -c LogIn -i"
Write-Host ""
Write-Host " Then run the rest of the setup:"
Write-Host "   ./om_importck.ps1"
Write-Host "   ./om_importrt.ps1"
Write-Host "==================================================================="
Write-Host ""
