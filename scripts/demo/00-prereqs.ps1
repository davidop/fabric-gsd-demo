Write-Host "Checking demo prerequisites..." -ForegroundColor Cyan

$commands = @("git", "python", "az", "pwsh")
foreach ($cmd in $commands) {
    $found = Get-Command $cmd -ErrorAction SilentlyContinue
    if ($null -eq $found) {
        Write-Warning "$cmd not found"
    } else {
        Write-Host "✓ $cmd -> $($found.Source)"
    }
}

Write-Host "\nPowerShell:" $PSVersionTable.PSVersion.ToString()
Write-Host "\nNext: run scripts/validation/validate-repo.ps1" -ForegroundColor Green
