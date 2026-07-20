param (
    [string]$configuration = "Release"
)

octo-cli -c EnableCommunication
octo-cli -c EnableReporting
octo-cli -c ImportFromCatalog -cn PublicGitHubCatalog -m Basic-2.0.2 -w
octo-cli -c ImportCk -f ../src/ProcessAutomationDemo/bin/$configuration/net10.0/octo-ck-libraries/ProcessAutomationDemo/out/ck-accountingdemo-2.yaml -w

# The mesh adapter loads its CK cache once, at container startup — which in
# the getting-started setup happens before this tenant exists or has
# reporting enabled. Without a restart, the first document upload fails with
# "RtCkTypeId 'System.Reporting/FolderRoot' not found in CkCache" (AB#4444).
if (Get-Command docker -ErrorAction SilentlyContinue) {
    Write-Host "Restarting octo-mesh-adapter so it picks up the newly enabled CK models..."
    docker restart octo-mesh-adapter
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Could not restart 'octo-mesh-adapter'. Restart the mesh adapter manually before uploading documents."
    }
}
else {
    Write-Warning "docker not found. Restart the mesh adapter manually before uploading documents, or its CK cache will miss the models enabled above."
}
