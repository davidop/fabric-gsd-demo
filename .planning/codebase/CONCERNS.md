# Codebase Concerns

**Analysis Date:** 2026-06-26

## Tech Debt

**Illustrative Fabric definitions in the active source tree:**
- Issue: `fabric-src/` currently contains only a Lakehouse and Notebook, and the notebook body is a placeholder.
- Files: `fabric-src/lakehouse_fabricgsd_dev_001.Lakehouse/.platform`, `fabric-src/nb_fabricgsd_dev_weu_001.Notebook/notebook-content.py`
- Impact: The committed demo does not yet reflect the full sales analytics scenario described in `docs/gsd/STATE.md` and `README.md`.
- Fix approach: Export or author the full set of Fabric items into `fabric-src/` and replace placeholder notebook content with the intended transformation logic.

**Duplicate demo trees increase confusion:**
- Issue: Both `fabric-src/` and `fabric-src.backup/` exist, but they represent different levels of completeness.
- Files: `fabric-src/`, `fabric-src.backup/`
- Impact: A presenter or contributor can easily edit the wrong tree or assume the backup tree is the active deployment source.
- Fix approach: Document the authoritative tree more explicitly or remove the backup copy once the active tree is fully populated.

## Known Bugs

**No discovered runtime bug in the PowerShell deployment path:**
- Symptoms: Not detected from static inspection.
- Files: `scripts/fabric/deploy-bulk-import.ps1`, `scripts/fabric/export-workspace.ps1`
- Trigger: Not established.
- Workaround: Use `-DryRun` before real Fabric calls.

## Security Considerations

**Secret handling is externalized but still fragile:**
- Risk: Fabric tenant IDs, client IDs, secrets, and workspace IDs are required at runtime and can leak if copied into logs or sample files.
- Files: `.env.sample`, `.env`, `deployment.parameters.json`, `scripts/fabric/Get-FabricAccessToken.ps1`
- Current mitigation: `.env` is ignored by Git, `.env.sample` exists as the template, and scripts read from environment variables.
- Recommendations: Keep secrets in GitHub environment secrets or local environment variables only, and avoid expanding debug output around authentication.

## Performance Bottlenecks

**Bulk import/export is file-by-file and synchronous at the scripting layer:**
- Problem: The scripts walk the entire tree, base64-encode payloads, and poll long-running operations in a serial loop.
- Files: `scripts/fabric/deploy-bulk-import.ps1`, `scripts/fabric/export-workspace.ps1`
- Cause: The demo prioritizes clarity over throughput.
- Improvement path: Keep the current flow for demoability, but separate larger item sets into smaller deploy batches if the repo grows.

## Fragile Areas

**Repository validation mirrors only a minimal subset of Fabric reality:**
- Files: `scripts/validation/validate-repo.ps1`, `tests/test_repo_structure.py`
- Why fragile: The checks confirm naming and `.platform` presence, but not the semantic correctness of each item definition.
- Safe modification: Extend checks incrementally and keep them aligned with exported Fabric definitions.
- Test coverage: Only filesystem-level assertions are currently present.

**Deployment payload shape may diverge by item type or Fabric API version:**
- Files: `scripts/fabric/deploy-bulk-import.ps1`, `scripts/fabric/export-workspace.ps1`
- Why fragile: The code intentionally treats exported payloads as opaque, and the comments note that the API shape can evolve.
- Safe modification: Re-export from the target tenant when changing item types or API versions, then validate with `-DryRun`.
- Test coverage: No automated API contract test is present.

## Scaling Limits

**Current repository scale is demo-sized:**
- Current capacity: Two active Fabric item folders in `fabric-src/`, with a fuller example tree in `fabric-src.backup/`.
- Limit: Validation and deployment assumptions are tuned to a small number of item directories.
- Scaling path: Introduce item-level manifests or more granular tests if the tree expands materially.

## Dependencies at Risk

**PowerShell and Fabric API contract stability:**
- Risk: The demo flow depends on PowerShell availability and Fabric REST behavior.
- Impact: A minor API or authentication change can stop export/import at runtime.
- Migration plan: Preserve `-DryRun`, keep exported examples current, and pin operational instructions in the runbook.

## Missing Critical Features

**No end-to-end authored sales pipeline in the active source tree:**
- Problem: The declared scenario includes a pipeline, semantic model, and report, but the active `fabric-src/` tree does not contain those items.
- Blocks: A complete demo of the full medallion-style workflow.

## Test Coverage Gaps

**Fabric definition semantics are not exercised by tests:**
- What's not tested: JSON schema correctness, notebook content semantics, bulk import payload compatibility, and live API responses.
- Files: `fabric-src/`, `scripts/fabric/*.ps1`, `tests/test_repo_structure.py`
- Risk: The repo can pass structural checks while still failing at deployment time.
- Priority: High.

---

*Concerns audit: 2026-06-26*