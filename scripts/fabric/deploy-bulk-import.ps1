param(
    [string]$TenantId = $env:FABRIC_TENANT_ID,
    [string]$ClientId = $env:FABRIC_CLIENT_ID,
    [string]$ClientSecret = $env:FABRIC_CLIENT_SECRET,
    [string]$TargetWorkspaceId = $env:FABRIC_TARGET_WORKSPACE_ID,
    [string]$ItemRoot = $(if ($env:FABRIC_ITEM_ROOT) { $env:FABRIC_ITEM_ROOT } else { "fabric-src" }),
    [string]$FabricApiBase = $(if ($env:FABRIC_API_BASE) { $env:FABRIC_API_BASE } else { "https://api.fabric.microsoft.com/v1" }),
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

Write-Host "Validating repository before deployment..." -ForegroundColor Cyan
pwsh ./scripts/validation/validate-repo.ps1 -ItemRoot $ItemRoot

$itemFolders = Get-ChildItem $ItemRoot -Directory
Write-Host "Items selected for deployment:" -ForegroundColor Cyan
$itemFolders | ForEach-Object { Write-Host " - $($_.Name)" }

if ($DryRun) {
    Write-Host "\nDRY RUN: no call will be made to Fabric." -ForegroundColor Yellow
    Write-Host "Target workspace: $TargetWorkspaceId"
    Write-Host "Item root: $ItemRoot"
    Write-Host "API base: $FabricApiBase"
    Write-Host "\nFor real deployment, provide TenantId, ClientId, ClientSecret and TargetWorkspaceId."
    exit 0
}

foreach ($required in @("TenantId", "ClientId", "ClientSecret", "TargetWorkspaceId")) {
    if ([string]::IsNullOrWhiteSpace((Get-Variable $required).Value)) {
        throw "$required is required for real deployment."
    }
}

$token = & ./scripts/fabric/Get-FabricAccessToken.ps1 -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret
$headers = @{ Authorization = "Bearer $token"; "Content-Type" = "application/json" }

# NOTE:
# Microsoft Fabric Bulk Import API accepts a folder/exported item definition payload.
# Exact payload shape can evolve and may differ by item type. Use this script as the
# demo orchestration point and adapt Build-BulkImportPayload once you export a real
# definition folder from your Dev workspace.
function Build-BulkImportPayload {
    param([string]$Root)

    $rootPath = (Resolve-Path $Root).Path
    $definitionParts = @()
    foreach ($folder in Get-ChildItem $rootPath -Directory) {
        foreach ($file in Get-ChildItem $folder.FullName -File -Recurse -Force) {
                    $relativePath = $file.FullName.Substring($rootPath.Length).TrimStart('\', '/').Replace('\', '/')
            $relativePath = "/$relativePath"

            $content = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((Get-Content $file.FullName -Raw)))
            $definitionParts += @{ path = $relativePath; payload = $content; payloadType = "InlineBase64" }
        }
    }

    return @{
        definitionParts = $definitionParts
        options = @{ allowPairingByName = $true }
    } | ConvertTo-Json -Depth 20
}

$payload = Build-BulkImportPayload -Root $ItemRoot
$uri = "$FabricApiBase/workspaces/$TargetWorkspaceId/items/bulkImportDefinitions?beta=true"

Write-Host "Calling Fabric Bulk Import endpoint..." -ForegroundColor Cyan
Write-Host $uri

$response = Invoke-WebRequest -Method Post -Uri $uri -Headers $headers -Body $payload

if ($response.StatusCode -eq 200) {
    $body = $response.Content | ConvertFrom-Json
    $body | ConvertTo-Json -Depth 20
    exit 0
}

if ($response.StatusCode -eq 202) {
    $operationIdValue = $response.Headers["x-ms-operation-id"]
    $operationId = if ($operationIdValue -is [System.Array]) { $operationIdValue[0] } else { $operationIdValue }

    $locationValue = $response.Headers.Location
    $location = if ($locationValue -is [System.Array]) { $locationValue[0] } else { $locationValue }

    Write-Host "Bulk import accepted (async)." -ForegroundColor Yellow
    if (-not [string]::IsNullOrWhiteSpace($operationId)) {
        Write-Host "Operation Id: $operationId"
    }

    if ([string]::IsNullOrWhiteSpace($location)) {
        Write-Host "No location header returned to poll status. Check workspace for imported items." -ForegroundColor Yellow
        exit 0
    }

    $maxAttempts = 30
    for ($attempt = 1; $attempt -le $maxAttempts; $attempt++) {
        $poll = Invoke-WebRequest -Method Get -Uri $location -Headers $headers

        if ($poll.StatusCode -eq 200) {
            $pollBody = $poll.Content | ConvertFrom-Json

            if ($pollBody.PSObject.Properties.Name -contains "importItemDefinitionsDetails") {
                $pollBody | ConvertTo-Json -Depth 20
                exit 0
            }

            $status = if ($pollBody.PSObject.Properties.Name -contains "status") { "$($pollBody.status)" } else { "" }
            if ($status -eq "Succeeded") {
                Write-Host "Bulk import completed successfully." -ForegroundColor Green
                $pollBody | ConvertTo-Json -Depth 20
                exit 0
            }

            if ($status -eq "Failed") {
                throw "Bulk import operation failed: $($poll.Content)"
            }
        }

        if ($poll.StatusCode -eq 202) {
            # Operation still running.
        }

        $retryAfter = $poll.Headers["Retry-After"]
        $waitSeconds = 5
        $parsedRetryAfter = 0
        if (-not [string]::IsNullOrWhiteSpace($retryAfter) -and [int]::TryParse($retryAfter, [ref]$parsedRetryAfter)) {
            $waitSeconds = $parsedRetryAfter
        }
        Start-Sleep -Seconds $waitSeconds
    }

    Write-Host "Bulk import is still running. Check workspace or rerun later to verify final state." -ForegroundColor Yellow
    exit 0
}

throw "Unexpected bulk import response status code: $($response.StatusCode)"
