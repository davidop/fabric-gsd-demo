# Event Demo Runbook

## Demo 0 - Setup check

```powershell
pwsh ./scripts/demo/00-prereqs.ps1
```

Expected result: versions of PowerShell, Git, Python and Azure CLI.

## Demo 1 - From requirement to GSD state

Open:

- `docs/gsd/STATE.md`
- `docs/gsd/CONTEXT.md`
- `docs/gsd/PLAN.md`

Say:

> We are not asking AI to randomly generate Fabric JSON. We are anchoring the work in context, decisions and verification.

## Demo 2 - Inspect Fabric as Code structure

```powershell
Get-ChildItem ./fabric-src -Directory
```

Then inspect `.platform` files.

## Demo 3 - Validate conventions

```powershell
pwsh ./scripts/validation/validate-repo.ps1
```

Optional controlled failure:

```powershell
Rename-Item ./fabric-src/SalesLakehouse.Lakehouse/.platform .platform.bak
pwsh ./scripts/validation/validate-repo.ps1
Rename-Item ./fabric-src/SalesLakehouse.Lakehouse/.platform.bak .platform
```

## Demo 4 - Dry-run deployment

```powershell
pwsh ./scripts/fabric/deploy-bulk-import.ps1 -DryRun
```

## Demo 5 - Real deployment

Only run if the environment is ready.

```powershell
pwsh ./scripts/fabric/deploy-bulk-import.ps1 `
  -TenantId $env:FABRIC_TENANT_ID `
  -ClientId $env:FABRIC_CLIENT_ID `
  -ClientSecret $env:FABRIC_CLIENT_SECRET `
  -TargetWorkspaceId $env:FABRIC_TARGET_WORKSPACE_ID
```

## Backup plan

If live Fabric deployment fails:

1. Show dry-run payload.
2. Show GitHub Actions workflow.
3. Show Fabric workspace manually with pre-created items.
4. Explain failure as a real-world reason for DevOps gates and deployment rehearsals.
