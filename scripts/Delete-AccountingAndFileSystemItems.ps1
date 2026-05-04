#!/usr/bin/env pwsh
param(
    [string]$tenant = "meshtest",

    [string]$BaseUrl = "https://localhost:5001",

    [string]$AuthToken,

    [int]$BatchSize = 50,

    [switch]$Force
)

# Construct GraphQL endpoint
$graphqlEndpoint = "$BaseUrl/tenants/$tenant/graphql"
Write-Host "Using GraphQL Endpoint: $graphqlEndpoint" -ForegroundColor Cyan

# Configure headers
$headers = @{
    "Content-Type" = "application/json"
}

if ($AuthToken) {
    $headers["Authorization"] = "Bearer $AuthToken"
}

Write-Host "Connecting to: $graphqlEndpoint" -ForegroundColor Green

# Query to retrieve all items
$query = @'
query {
  runtime {
    accountingDemoAccountingDocument {
      items {
        rtId
        ckTypeId
      }
    }
    systemReportingFileSystemItem {
      items {
        rtId
        ckTypeId
      }
    }
  }
}
'@

try {
    # Fetch items
    Write-Host "Fetching entities..." -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri $graphqlEndpoint -Method Post -Headers $headers -Body (@{query = $query} | ConvertTo-Json)
    
    # Collect entities to delete
    $entitiesToDelete = @()
    
    # Accounting Documents
    if ($response.data.runtime.accountingDemoAccountingDocument.items) {
        $accountingDocs = $response.data.runtime.accountingDemoAccountingDocument.items
        Write-Host "  Accounting Documents found: $($accountingDocs.Count)" -ForegroundColor Cyan
        $accountingDocs | ForEach-Object {
            $entitiesToDelete += @{
                ckTypeId = $_.ckTypeId
                rtId = $_.rtId
            }
        }
    }
    
    # File System Items
    if ($response.data.runtime.systemReportingFileSystemItem.items) {
        $fileSystemItems = $response.data.runtime.systemReportingFileSystemItem.items
        Write-Host "  File System Items found: $($fileSystemItems.Count)" -ForegroundColor Cyan
        $fileSystemItems | ForEach-Object {
            $entitiesToDelete += @{
                ckTypeId = $_.ckTypeId
                rtId = $_.rtId
            }
        }
    }
    
    if ($entitiesToDelete.Count -eq 0) {
        Write-Host "No entities found to delete." -ForegroundColor Green
        exit 0
    }
    
    Write-Host "`nTotal: $($entitiesToDelete.Count) entities to delete" -ForegroundColor Yellow
    
    # Confirmation (skipped when -Force is given, e.g. from automation)
    if (-not $Force) {
        $confirmation = Read-Host "Really delete all $($entitiesToDelete.Count) entities? (y/n)"
        if ($confirmation -ne 'y') {
            Write-Host "Aborted." -ForegroundColor Red
            exit 0
        }
    }
    
    # Delete in batches
    $totalBatches = [Math]::Ceiling($entitiesToDelete.Count / $BatchSize)
    Write-Host "`nDeleting in $totalBatches batches of max. $BatchSize entities each..." -ForegroundColor Yellow
    
    $successCount = 0
    $errorCount = 0
    
    for ($i = 0; $i -lt $entitiesToDelete.Count; $i += $BatchSize) {
        $batch = $entitiesToDelete[$i..[Math]::Min($i + $BatchSize - 1, $entitiesToDelete.Count - 1)]
        $currentBatch = [Math]::Floor($i/$BatchSize) + 1
        
        # Create mutation
        $entitiesJson = ($batch | ConvertTo-Json -Compress)
        if ($batch.Count -eq 1) {
            # Add array brackets for single element
            $entitiesJson = "[$entitiesJson]"
        }

        $deleteMutation = @"
mutation {
  runtime {
    runtimeEntities {
      delete(
        entities: $entitiesJson
      )
    }
  }
}
"@
        # Replace " with nothing to avoid escaping issues
        $deleteMutation = $deleteMutation -replace '"ckTypeId"', 'ckTypeId'
        $deleteMutation = $deleteMutation -replace '"rtId"', 'rtId'
        Write-Host $deleteMutation

        try {
            Write-Host "  Batch $currentBatch/$totalBatches Deleting $($batch.Count) entities..." -NoNewline
            $deleteResponse = Invoke-RestMethod -Uri $graphqlEndpoint -Method Post -Headers $headers -Body (@{query = $deleteMutation} | ConvertTo-Json)
            
            if ($deleteResponse.errors) {
                Write-Host " ERROR" -ForegroundColor Red
                Write-Host "    $($deleteResponse.errors | ConvertTo-Json -Compress)" -ForegroundColor Red
                $errorCount += $batch.Count
            } else {
                Write-Host " OK" -ForegroundColor Green
                $successCount += $batch.Count
            }
        }
        catch {
            Write-Host " ERROR" -ForegroundColor Red
            Write-Host "    $_" -ForegroundColor Red
            $errorCount += $batch.Count
        }
        
        # Short pause between batches
        if ($i + $BatchSize -lt $entitiesToDelete.Count) {
            Start-Sleep -Milliseconds 100
        }
    }
    
    # Summary
    Write-Host "`n=== Summary ===" -ForegroundColor Cyan
    Write-Host "Successfully deleted: $successCount" -ForegroundColor Green
    if ($errorCount -gt 0) {
        Write-Host "Errors: $errorCount" -ForegroundColor Red
    }
    Write-Host "Done!" -ForegroundColor Green
}
catch {
    Write-Host "`nERROR: $_" -ForegroundColor Red
    exit 1
}
