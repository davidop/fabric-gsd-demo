# External Integrations

**Analysis Date:** 2026-06-26

## APIs & External Services

**Microsoft Fabric:**
- Microsoft Fabric REST API - Used for workspace item listing, bulk export, and bulk import in `scripts/fabric/export-workspace.ps1` and `scripts/fabric/deploy-bulk-import.ps1`.
  - SDK/Client: direct REST calls through PowerShell `Invoke-RestMethod` and `Invoke-WebRequest`
  - Auth: `FABRIC_TENANT_ID`, `FABRIC_CLIENT_ID`, `FABRIC_CLIENT_SECRET`

**Microsoft Entra ID:**
- OAuth2 token endpoint - Used to mint a Fabric API access token in `scripts/fabric/Get-FabricAccessToken.ps1`.
  - SDK/Client: raw token request to `https://login.microsoftonline.com/<tenant>/oauth2/v2.0/token`
  - Auth: tenant ID, client ID, client secret

**GitHub:**
- GitHub repository and Actions - Used for publishing and CI/CD in `scripts/demo/02-publish-to-github.ps1` and `.github/workflows/*.yml`.
  - SDK/Client: GitHub CLI in the publish helper; GitHub Actions for automation
  - Auth: GitHub credentials or existing repo access

## Data Storage

**Databases:**
- Microsoft Fabric Lakehouse - The active committed lakehouse item lives in `fabric-src/lakehouse_fabricgsd_dev_001.Lakehouse/`.
  - Connection: Fabric workspace context, not a direct connection string in the repo
  - Client: Fabric item definition and REST APIs

**File Storage:**
- OneLake / Fabric item definition folders - The repo stores item definitions as filesystem directories under `fabric-src/` and exported snapshots under `fabric-export/`.

**Caching:**
- None detected.

## Authentication & Identity

**Auth Provider:**
- Microsoft Entra ID service principal - The deployment scripts authenticate against Fabric using client credentials.
  - Implementation: raw OAuth token acquisition in `scripts/fabric/Get-FabricAccessToken.ps1`

## Monitoring & Observability

**Error Tracking:**
- None detected.

**Logs:**
- PowerShell console output is the primary runtime feedback channel for validation, export, and deployment scripts.
- GitHub Actions job logs provide CI visibility.

## CI/CD & Deployment

**Hosting:**
- Microsoft Fabric workspaces via bulk import of item definitions.

**CI Pipeline:**
- GitHub Actions in `.github/workflows/validate.yml` and `.github/workflows/deploy-test.yml`.

## Environment Configuration

**Required env vars:**
- `FABRIC_TENANT_ID`
- `FABRIC_CLIENT_ID`
- `FABRIC_CLIENT_SECRET`
- `FABRIC_SOURCE_WORKSPACE_ID`
- `FABRIC_TARGET_WORKSPACE_ID`
- `FABRIC_ITEM_ROOT`
- `FABRIC_API_BASE`

**Secrets location:**
- Local environment variables for scripts.
- GitHub repository or environment secrets for Actions.
- `.env` file exists in the repo root, while `.env.sample` provides the non-secret template.

## Webhooks & Callbacks

**Incoming:**
- None detected.

**Outgoing:**
- Fabric bulk export and bulk import API calls from `scripts/fabric/export-workspace.ps1` and `scripts/fabric/deploy-bulk-import.ps1`.

---

*Integration audit: 2026-06-26*