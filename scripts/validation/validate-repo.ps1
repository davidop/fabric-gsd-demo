param(
    [string]$ItemRoot = "fabric-src"
)

$ErrorActionPreference = "Stop"
$failures = New-Object System.Collections.Generic.List[string]

if (-not (Test-Path $ItemRoot)) {
    throw "Item root '$ItemRoot' does not exist."
}

$itemFolders = Get-ChildItem $ItemRoot -Directory
if ($itemFolders.Count -eq 0) {
    $failures.Add("No Fabric item folders found under $ItemRoot")
}

foreach ($folder in $itemFolders) {
    if ($folder.Name -notmatch "^[A-Za-z0-9]+\.(Lakehouse|Notebook|DataPipeline|SemanticModel|Report|Environment|Warehouse)$") {
        $failures.Add("Invalid item folder name: $($folder.Name)")
    }

    $platform = Join-Path $folder.FullName ".platform"
    if (-not (Test-Path $platform)) {
        $failures.Add("Missing .platform in $($folder.Name)")
        continue
    }

    try {
        $json = Get-Content $platform -Raw | ConvertFrom-Json
        if (-not $json.metadata.type) { $failures.Add(".platform metadata.type missing in $($folder.Name)") }
        if (-not $json.metadata.displayName) { $failures.Add(".platform metadata.displayName missing in $($folder.Name)") }
    }
    catch {
        $failures.Add("Invalid JSON in $($folder.Name)/.platform: $($_.Exception.Message)")
    }
}

if (-not (Test-Path "docs/gsd/STATE.md")) { $failures.Add("Missing docs/gsd/STATE.md") }
if (-not (Test-Path "docs/gsd/PLAN.md")) { $failures.Add("Missing docs/gsd/PLAN.md") }
if (-not (Test-Path "deployment.parameters.json")) { $failures.Add("Missing deployment.parameters.json") }

if ($failures.Count -gt 0) {
    Write-Host "Validation failed:" -ForegroundColor Red
    $failures | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
    exit 1
}

Write-Host "Validation passed. Fabric as Code repo structure looks consistent." -ForegroundColor Green
