param(
    [Parameter(Mandatory=$true)][string]$TenantId,
    [Parameter(Mandatory=$true)][string]$ClientId,
    [Parameter(Mandatory=$true)][string]$ClientSecret
)

$body = @{
    client_id     = $ClientId
    scope         = "https://api.fabric.microsoft.com/.default"
    client_secret = $ClientSecret
    grant_type    = "client_credentials"
}

$response = Invoke-RestMethod `
    -Method Post `
    -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" `
    -Body $body `
    -ContentType "application/x-www-form-urlencoded"

return $response.access_token
