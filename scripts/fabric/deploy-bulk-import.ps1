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

    $items = @()
    foreach ($folder in Get-ChildItem $Root -Directory) {
        $platform = Get-Content (Join-Path $folder.FullName ".platform") -Raw | ConvertFrom-Json
        $parts = @()
        foreach ($file in Get-ChildItem $folder.FullName -File | Where-Object { $_.Name -ne ".platform" }) {
            $content = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((Get-Content $file.FullName -Raw)))
            $parts += @{ path = $file.Name; payload = $content; payloadType = "InlineBase64" }
        }
        $items += @{
            displayName = $platform.metadata.displayName
            type = $platform.metadata.type
            definition = @{ parts = $parts }
        }
    }
    return @{ items = $items } | ConvertTo-Json -Depth 20
}

$payload = Build-BulkImportPayload -Root $ItemRoot
$uri = "$FabricApiBase/workspaces/$TargetWorkspaceId/items/import"

Write-Host "Calling Fabric Bulk Import endpoint..." -ForegroundColor Cyan
Write-Host $uri

$response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $payload
$response | ConvertTo-Json -Depth 20
