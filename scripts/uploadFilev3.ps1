param (
    [string]$file,
    [string]$tenant = "meshtest",
    [string]$baseUrl = "https://localhost:5020"
)

# check if file parameter is provided
if (-not $file) {
    Write-Host "Please provide a file path as a parameter."
    exit 1
}

if (-not (Test-Path -Path $file)) {
    Write-Host "File not found: $file"
    exit 1
}

# Make full path
$file = (Resolve-Path $file).Path
Write-Host "Uploading file: $file"

$pdfBytes = [System.IO.File]::ReadAllBytes($file)
$response = Invoke-WebRequest -Uri "$baseUrl/$tenant/uploadaccountingdocumentv3" `
    -Method Post `
    -Body $pdfBytes `
    -ContentType "application/pdf"

Write-Host $response.StatusCode
Write-Host $response.Content