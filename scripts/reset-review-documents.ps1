param(
    [string]$BaseUrl = "https://localhost:5001",

    [string]$tenant = "meshtest",

    [Parameter(Mandatory=$true)]
    [string]$AuthToken
)

$graphqlEndpoint = "$BaseUrl/tenants/$tenant/graphql"
Write-Host "Using GraphQL Endpoint: $graphqlEndpoint" -ForegroundColor Cyan

$headers = @{
    "Authorization" = "Bearer $AuthToken"
    "Content-Type" = "application/json"
}

# Query to fetch documents in REVIEW status
$query = @'
{
  "query": "query { runtime { accountingDemoAccountingDocument(fieldFilter: [{attributePath: \"documentState\", comparisonValue: \"REVIEW\", operator: EQUALS}]) { items { rtId } } } }"
}
'@

try {
    # Fetch documents
    Write-Host "Fetching documents in REVIEW status..." -ForegroundColor Cyan
    $response = Invoke-RestMethod -Uri $graphqlEndpoint -Method Post -Headers $headers -Body $query
    $documents = $response.data.runtime.accountingDemoAccountingDocument.items
    
    if ($documents.Count -eq 0) {
        Write-Host "No documents found in REVIEW status." -ForegroundColor Yellow
        exit 0
    }
    
    Write-Host "Found: $($documents.Count) documents" -ForegroundColor Green
    
    # Reset status for each document
    $successCount = 0
    foreach ($doc in $documents) {
        $mutation = @"
{
  "query": "mutation { runtime { accountingDemoAccountingDocuments { update(entities: [{rtId: \"$($doc.rtId)\", item: {comment: null, documentState: NEW}}]) { rtId } } } }"
}
"@
        
        try {
            $updateResponse = Invoke-RestMethod -Uri $graphqlEndpoint -Method Post -Headers $headers -Body $mutation
            Write-Host "✓ Updated: $($doc.rtId)" -ForegroundColor Green
            $successCount++
        }
        catch {
            Write-Host "✗ Error for $($doc.rtId): $_" -ForegroundColor Red
        }
    }
    
    Write-Host "`nCompleted: $successCount of $($documents.Count) documents reset" -ForegroundColor Cyan
}
catch {
    Write-Error "Error fetching documents: $_"
    exit 1
}
