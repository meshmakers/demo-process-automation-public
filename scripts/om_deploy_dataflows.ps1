# Deploys every DataFlow defined in data/_pipelines/*.yaml to the mesh adapter.
# Uses the active octo-cli context, so run this after om_importrt.ps1 (and,
# if you also ran om_update_2_anomaly.ps1, after that too). Idempotent:
# DeployDataFlow is safe to re-run on an already-deployed DataFlow.
#
# DataFlows found on disk but not yet imported into the tenant (the 4
# detect_anomalies_* pipelines before om_update_2_anomaly.ps1 has run) are
# reported as "not yet imported" and skipped — they are not deploy failures
# and do not affect the exit code (AB#4448).

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
$notImported = @()
$deployed = @()

foreach ($df in $dataflows) {
    # Existence pre-check: distinguish "not yet imported" (expected before
    # om_update_2_anomaly.ps1) from a genuine deploy failure.
    octo-cli -c GetDataFlowStatus -id $df.RtId -j *> $null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Skipping $($df.RtId) ($($df.Source)) - not yet imported into this tenant." -ForegroundColor Yellow
        $notImported += $df.RtId
        Write-Host ""
        continue
    }

    Write-Host "Deploying $($df.RtId) ($($df.Source))..." -ForegroundColor Cyan
    octo-cli -c DeployDataFlow -id $df.RtId
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  FAILED (exit $LASTEXITCODE)" -ForegroundColor Red
        $failed += $df.RtId
    }
    else {
        $deployed += $df.RtId
    }
    Write-Host ""
}

Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host "Total:            $($dataflows.Count)"
Write-Host "Deployed:         $($deployed.Count)" -ForegroundColor Green
if ($notImported.Count -gt 0) {
    Write-Host "Not yet imported: $($notImported.Count) (expected before om_update_2_anomaly.ps1)" -ForegroundColor Yellow
    $notImported | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
}
if ($failed.Count -gt 0) {
    Write-Host "Failed:           $($failed.Count)" -ForegroundColor Red
    $failed | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    exit 1
}
