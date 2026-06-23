Write-Host "GSD → Fabric as Code demo" -ForegroundColor Cyan
Write-Host "1. Intent: docs/gsd/STATE.md"
Write-Host "2. Context: docs/gsd/CONTEXT.md"
Write-Host "3. Plan: docs/gsd/PLAN.md"
Write-Host "4. Fabric definitions: fabric-src/"
Write-Host "\nRepository item folders:" -ForegroundColor Yellow
Get-ChildItem ./fabric-src -Directory | Select-Object Name
Write-Host "\nAsk Copilot: 'Using docs/gsd, add a customer satisfaction notebook item following repo conventions.'"
