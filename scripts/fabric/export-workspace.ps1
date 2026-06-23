param(
    [string]$TenantId = $env:FABRIC_TENANT_ID,
    [string]$ClientId = $env:FABRIC_CLIENT_ID,
    [string]$ClientSecret = $env:FABRIC_CLIENT_SECRET,
    [string]$SourceWorkspaceId = $env:FABRIC_SOURCE_WORKSPACE_ID,
    [string]$OutputPath = "fabric-export",
    [string]$FabricApiBase = $(if ($env:FABRIC_API_BASE) { $env:FABRIC_API_BASE } else { "https://api.fabric.microsoft.com/v1" })
)

$ErrorActionPreference = "Stop"
foreach ($required in @("TenantId", "ClientId", "ClientSecret", "SourceWorkspaceId")) {
    if ([string]::IsNullOrWhiteSpace((Get-Variable $required).Value)) {
        throw "$required is required."
    }
}

New-Item -ItemType Directory -Force -Path $OutputPath | Out-Null
$token = & ./scripts/fabric/Get-FabricAccessToken.ps1 -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret
$headers = @{ Authorization = "Bearer $token"; "Content-Type" = "application/json" }

$itemsUri = "$FabricApiBase/workspaces/$SourceWorkspaceId/items"
$items = Invoke-RestMethod -Method Get -Uri $itemsUri -Headers $headers
$items.value | ConvertTo-Json -Depth 20 | Set-Content (Join-Path $OutputPath "workspace-items.json")

Write-Host "Exported workspace item list to $OutputPath/workspace-items.json" -ForegroundColor Green
Write-Host "Next step: use Fabric Get Item Definition API per supported item and copy exported folders into fabric-src/."
