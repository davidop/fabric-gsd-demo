# Phase 1 Requirements: Stabilize Demo

## Business Requirements

### BR-1: Demonstrate spec-driven workflow
- User expectation: See how GSD anchors AI-generated code in context and decisions
- Demo flow: Open STATE.md → show intent → generate code → validate → deploy

### BR-2: Show Fabric as Code pattern
- User expectation: Understand that Fabric items are versioned in Git, not clicked in UI
- Demo flow: Inspect `.platform` metadata → show naming conventions → validate locally

### BR-3: Enable safe dry-run demonstration
- User expectation: See deployment mechanics without risk
- Demo flow: Run `deploy-bulk-import.ps1 -DryRun` → inspect what would deploy → optional real deployment

### BR-4: Provide repeatable narrative
- User expectation: Demo can be executed independently by team members
- Demo flow: Follow RUNBOOK.md end-to-end in demo environment

## Technical Requirements

### TR-1: Notebook completeness
- Transform `data/raw/sales.csv` into medallion-style curated tables
- Calculate: Revenue, Cost, Margin, MarginPercentage
- Handle edge cases (Revenue=0 → MarginPercentage=0)
- Output: DataFrame ready for lakehouse ingestion

### TR-2: Fabric item validity
- All items under `fabric-src/` must have `.platform` metadata
- `.platform` must include: `metadata.type`, `metadata.displayName`, `config.logicalId`
- Item folder naming convention: `[Name].[ItemType]`
  - Supported types: Lakehouse, Notebook, DataPipeline, SemanticModel, Report
- Current items:
  - `lakehouse_fabricgsd_dev_001.Lakehouse`
  - `nb_fabricgsd_dev_weu_001.Notebook`

### TR-3: Validation gate
- `scripts/validation/validate-repo.ps1` must pass
- Checks:
  - Item folder naming convention
  - `.platform` presence and schema
  - Required GSD docs (STATE.md, PLAN.md, CONTEXT.md)
  - `deployment.parameters.json` presence
- Exit code 0 = pass, exit code 1 = fail

### TR-4: Deployment script safety
- `scripts/fabric/deploy-bulk-import.ps1 -DryRun` safe (no actual deployment)
- Show what would deploy without executing
- Support parameterized workspace/lakehouse IDs
- No hardcoded secrets, GUIDs, connection strings

### TR-5: Documentation alignment
- RUNBOOK.md must reference correct artifact names:
  - ✅ `lakehouse_fabricgsd_dev_001.Lakehouse`
  - ✅ `nb_fabricgsd_dev_weu_001.Notebook`
  - ❌ Old names (SalesLakehouse, TransformSales, etc.)
- All references to artifacts use correct names

### TR-6: GSD operational artifacts
- `.planning/PROJECT.md` — project context
- `.planning/config.json` — GSD configuration
- `.planning/ROADMAP.md` — phase structure
- `.planning/REQUIREMENTS.md` — this document
- `.planning/STATE.md` — operational state

## Acceptance Criteria

| ID | Criterion | Status |
|---|---|---|
| AC-1 | `scripts/validation/validate-repo.ps1` exits 0 | ⏳ |
| AC-2 | `scripts/fabric/deploy-bulk-import.ps1 -DryRun` completes | ⏳ |
| AC-3 | Notebook executes without errors (import data, calculate metrics) | ⏳ |
| AC-4 | RUNBOOK.md executed end-to-end | ⏳ |
| AC-5 | All GSD artifacts created and linked | ⏳ |
| AC-6 | No hardcoded secrets, GUIDs in code | ✅ |
| AC-7 | Demo is reproducible by team members | ⏳ |

## Constraints

- ❌ Do not create parallel demo structure
- ❌ Do not invent Microsoft Fabric schemas
- ❌ Do not change real artifact names
- ❌ Do not include secrets
- ❌ Do not deploy to Fabric (Phase 1)
- ❌ Do not relax validation gates
- ❌ Do not replace placeholders with real GUIDs
