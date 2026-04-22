param (
    [string]$tenantId = "processautomationdemo",
    [string]$systemContextName = "local_octosystem",
    [string]$identityUri = "https://localhost:5003/",
    [string]$assetUri = "https://localhost:5001/",
    [string]$botUri = "https://localhost:5009/",
    [string]$communicationUri = "https://localhost:5015/",
    [string]$reportingUri = "https://localhost:5007/"
)

# Create must run from a system-tenant context. Its auth claims stay
# valid regardless of which tenants come and go, and `Create` auto-
# provisions the current system user as admin of the new tenant.

octo-cli -c UseContext -n $systemContextName

# Create the tenant (auto-provisions the current user)
octo-cli -c Create -tid $tenantId -db $tenantId

# Register the per-tenant context that om_delete_tenants.ps1 removes
# (and that a first-time user doesn't yet have).
$tenantContextName = "local_$tenantId"
octo-cli -c AddContext `
    -n $tenantContextName `
    -isu $identityUri `
    -asu $assetUri `
    -bsu $botUri `
    -csu $communicationUri `
    -rsu $reportingUri `
    -tid $tenantId

# Switch to the new tenant context so subsequent tenant-scoped
# commands (EnableCommunication, ImportCk, ImportRt ...) operate
# on the new tenant.
octo-cli -c UseContext -n $tenantContextName

Write-Host ""
Write-Host "==================================================================="
Write-Host " Tenant '$tenantId' created and provisioned."
Write-Host " Active context switched to '$tenantContextName'."
Write-Host ""
Write-Host " NEXT STEP (required, interactive):"
Write-Host "   octo-cli -c LogIn -i"
Write-Host ""
Write-Host " Then run the rest of the setup:"
Write-Host "   ./om_importck.ps1"
Write-Host "   ./om_importrt.ps1"
Write-Host "==================================================================="
Write-Host ""
