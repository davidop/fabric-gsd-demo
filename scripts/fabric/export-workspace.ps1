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

$exportUri = "$FabricApiBase/workspaces/$SourceWorkspaceId/items/bulkExportDefinitions?beta=true"
$exportBody = @{ mode = "All" } | ConvertTo-Json -Depth 5

Write-Host "Requesting bulk export of item definitions..." -ForegroundColor Cyan
$response = Invoke-WebRequest -Method Post -Uri $exportUri -Headers $headers -Body $exportBody

$result = $null
if ($response.StatusCode -eq 202) {
    $pollUriValue = $response.Headers.Location
    $pollUri = if ($pollUriValue -is [System.Array]) { $pollUriValue[0] } else { $pollUriValue }
    if ([string]::IsNullOrWhiteSpace($pollUri)) {
        throw "Bulk export returned 202 but no Location header was provided."
    }

    Write-Host "Bulk export accepted. Polling operation endpoint..." -ForegroundColor Yellow
    $maxAttempts = 20
    for ($attempt = 1; $attempt -le $maxAttempts; $attempt++) {
        $poll = Invoke-WebRequest -Method Get -Uri $pollUri -Headers $headers

        if ($poll.StatusCode -eq 200) {
            $pollBody = $poll.Content | ConvertFrom-Json

            # Some Fabric LRO endpoints return 200 while still running.
            if ($pollBody.PSObject.Properties.Name -contains "definitionParts") {
                $result = $pollBody
                break
            }

            $status = if ($pollBody.PSObject.Properties.Name -contains "status") { "$($pollBody.status)" } else { "" }
            if ($status -eq "Succeeded") {
                # Operation finished. Try to fetch the final result payload if provided via location header.
                $resultUriValue = $poll.Headers.Location
                $resultUri = if ($resultUriValue -is [System.Array]) { $resultUriValue[0] } else { $resultUriValue }

                if (-not [string]::IsNullOrWhiteSpace($resultUri)) {
                    $final = Invoke-WebRequest -Method Get -Uri $resultUri -Headers $headers
                    if ($final.StatusCode -eq 200) {
                        $finalBody = $final.Content | ConvertFrom-Json
                        if ($finalBody.PSObject.Properties.Name -contains "definitionParts") {
                            $result = $finalBody
                            break
                        }
                    }
                }

                $result = $pollBody
                break
            }

            if ($status -eq "Failed") {
                throw "Bulk export operation failed: $($poll.Content)"
            }

            $retryAfter = $poll.Headers["Retry-After"]
            $waitSeconds = 5
            $parsedRetryAfter = 0
            if (-not [string]::IsNullOrWhiteSpace($retryAfter) -and [int]::TryParse($retryAfter, [ref]$parsedRetryAfter)) {
                $waitSeconds = $parsedRetryAfter
            }
            Start-Sleep -Seconds $waitSeconds
            continue
        }

        if ($poll.StatusCode -eq 202) {
            $retryAfter = $poll.Headers["Retry-After"]
            $waitSeconds = 5
            $parsedRetryAfter = 0
            if (-not [string]::IsNullOrWhiteSpace($retryAfter) -and [int]::TryParse($retryAfter, [ref]$parsedRetryAfter)) {
                $waitSeconds = $parsedRetryAfter
            }
            Start-Sleep -Seconds $waitSeconds
            continue
        }

        throw "Unexpected poll response status code: $($poll.StatusCode)"
    }

    if ($null -eq $result) {
        throw "Timed out waiting for bulk export operation result."
    }
}
elseif ($response.StatusCode -eq 200) {
    $result = $response.Content | ConvertFrom-Json
}
else {
    throw "Unexpected bulk export response status code: $($response.StatusCode)"
}

$result | ConvertTo-Json -Depth 50 | Set-Content (Join-Path $OutputPath "bulk-export-response.json")

if ($null -eq $result.definitionParts -or $result.definitionParts.Count -eq 0) {
    throw "Bulk export completed but returned no definition parts."
}

$definitionsRoot = Join-Path $OutputPath "definitions"
New-Item -ItemType Directory -Force -Path $definitionsRoot | Out-Null

foreach ($part in $result.definitionParts) {
    if (-not $part.path -or -not $part.payload) {
        continue
    }

    $relativePath = $part.path.TrimStart('/') -replace '/', [System.IO.Path]::DirectorySeparatorChar
    $targetPath = Join-Path $definitionsRoot $relativePath
    $targetDir = Split-Path -Path $targetPath -Parent
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

    $bytes = [Convert]::FromBase64String($part.payload)
    [System.IO.File]::WriteAllBytes($targetPath, $bytes)
}

Write-Host "Exported workspace item list to $OutputPath/workspace-items.json" -ForegroundColor Green
Write-Host "Exported raw API response to $OutputPath/bulk-export-response.json" -ForegroundColor Green
Write-Host "Materialized import-ready definition files under $definitionsRoot" -ForegroundColor Green
Write-Host "Next step: replace folders under fabric-src/ with exported folders from $definitionsRoot" -ForegroundColor Yellow
