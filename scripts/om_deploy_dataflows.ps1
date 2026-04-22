# Deploys every DataFlow defined in data/_pipelines/*.yaml to the mesh adapter.
# Uses the active octo-cli context, so run this after om_importrt.ps1 (and,
# if you also ran om_update_2_anomaly.ps1, after that too). Idempotent:
# DeployDataFlow is safe to re-run on an already-deployed DataFlow.

$ErrorActionPreference = 'Stop'

$pipelineDir = Resolve-Path (Join-Path $PSScriptRoot '..' 'data' '_pipelines')
$yamls = Get-ChildItem -Path $pipelineDir -Filter '*.yaml' -File | Sort-Object Name

$dataflows = @()

foreach ($yaml in $yamls) {
    $currentRtId = $null
    foreach ($line in (Get-Content -LiteralPath $yaml.FullName)) {
        if ($line -match '^\s+-\s+rtId:\s+(\S+)') {
            $currentRtId = $Matches[1]
        }
        elseif ($line -match '^\s+ckTypeId:\s+System\.Communication/DataFlow\s*$' -and $currentRtId) {
            $dataflows += [PSCustomObject]@{
                RtId = $currentRtId
                Source = $yaml.Name
            }
            $currentRtId = $null
        }
    }
}

if ($dataflows.Count -eq 0) {
    Write-Host "No DataFlows found in $pipelineDir." -ForegroundColor Yellow
    exit 0
}

Write-Host "Found $($dataflows.Count) DataFlow(s) to deploy:" -ForegroundColor Cyan
$dataflows | ForEach-Object { Write-Host "  $($_.RtId)  ($($_.Source))" }
Write-Host ""

$failed = @()

foreach ($df in $dataflows) {
    Write-Host "Deploying $($df.RtId) ($($df.Source))..." -ForegroundColor Cyan
    octo-cli -c DeployDataFlow -id $df.RtId
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  FAILED (exit $LASTEXITCODE)" -ForegroundColor Red
        $failed += $df.RtId
    }
    Write-Host ""
}

Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host "Total:      $($dataflows.Count)"
Write-Host "Successful: $($dataflows.Count - $failed.Count)" -ForegroundColor Green
if ($failed.Count -gt 0) {
    Write-Host "Failed:     $($failed.Count)" -ForegroundColor Red
    $failed | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    exit 1
}
