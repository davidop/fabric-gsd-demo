# GSD State

## Session

**Stop Clicking: domina Microsoft Fabric con Fabric as Code, Copilot y GSD**

## Current goal

Build a demoable Microsoft Fabric data platform solution from a business requirement using a spec-driven workflow.

## Demo scenario

Contoso Retail wants a repeatable Fabric workspace for sales analytics:

- Raw sales CSV lands in OneLake/Lakehouse.
- A notebook transforms raw data into curated tables.
- A data pipeline orchestrates ingestion and transformation.
- A semantic model exposes sales KPIs.
- A report consumes the model.

## Constraints

- No manual clicking during the main demo.
- All deployable assets are versioned in Git.
- CI must validate conventions before deployment.
- Deployment must support dry-run and real execution.
- Secrets and environment IDs must be parameterized.

## Decisions

| Decision | Status | Rationale |
|---|---:|---|
| Use Fabric item definitions as deployable artifact | Accepted | Native ALM mechanism for Fabric items. |
| Use GSD for context/spec/process | Accepted | Keeps AI-generated changes aligned with intent. |
| Use PowerShell scripts for live demo | Accepted | Familiar for Microsoft audience. |
| Use Bulk Import path for deployment | Accepted | Best narrative fit for folder-based Git deployment. |
| Keep sample definitions illustrative unless exported from real workspace | Accepted | Fabric item schemas vary by type and evolve over time. |

## Risks

| Risk | Mitigation |
|---|---|
| API permissions fail live | Use `-DryRun` plus screenshots/video backup. |
| Item definition format differs by tenant/version | Export real definitions before event using `export-workspace.ps1`. |
| Workspace GUID replacement | Use `deployment.parameters.json` and parameter replacement hooks. |
| Copilot hallucinates schemas | Use GSD context, validation, and explicit TODO policy. |
