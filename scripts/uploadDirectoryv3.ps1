param (
    [string]$directory,
    [string]$tenant = "meshtest",
    [string]$baseUrl = "https://localhost:5020",
    [string]$filter = "*.pdf"
)

# Check if directory parameter is provided
if (-not $directory) {
    Write-Host "Please provide a directory path as a parameter."
    exit 1
}

if (-not (Test-Path -Path $directory -PathType Container)) {
    Write-Host "Directory not found: $directory"
    exit 1
}

# Make full path
$directory = (Resolve-Path $directory).Path
Write-Host "Uploading files from directory: $directory"
Write-Host "Filter: $filter"
Write-Host ""

# Get all files in directory
$files = Get-ChildItem -Path $directory -Filter $filter -File

if ($files.Count -eq 0) {
    Write-Host "No files found matching filter: $filter"
    exit 1
}

Write-Host "Found $($files.Count) file(s) to upload"
Write-Host ("=" * 50)

$successCount = 0
$failureCount = 0
$results = @()

foreach ($file in $files) {
    Write-Host "Uploading: $($file.Name)"
    
    try {
        $pdfBytes = [System.IO.File]::ReadAllBytes($file.FullName)
        
        $response = Invoke-WebRequest -Uri "$baseUrl/$tenant/uploadaccountingdocumentv3" `
            -Method Post `
            -Body $pdfBytes `
            -ContentType "application/pdf" `
            -ErrorAction Stop
        
        Write-Host "  Status: $($response.StatusCode) - Success" -ForegroundColor Green
        Write-Host "  Response: $($response.Content)"
        $successCount++
        
        $results += [PSCustomObject]@{
            File = $file.Name
            Status = $response.StatusCode
            Success = $true
            Response = $response.Content
        }
    }
    catch {
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        $failureCount++
        
        $results += [PSCustomObject]@{
            File = $file.Name
            Status = "Error"
            Success = $false
            Response = $_.Exception.Message
        }
    }
    
    Write-Host ""
}

# Summary
Write-Host ("=" * 50)
Write-Host "Upload Summary:"
Write-Host "  Total files: $($files.Count)"
Write-Host "  Successful: $successCount" -ForegroundColor Green
Write-Host "  Failed: $failureCount"
Write-Host ""

# Optional: Export results to CSV
$exportPath = Join-Path $directory "upload_results_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
$results | Export-Csv -Path $exportPath -NoTypeInformation
Write-Host "Results exported to: $exportPath"
