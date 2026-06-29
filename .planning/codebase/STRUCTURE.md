# Codebase Structure

**Analysis Date:** 2026-06-26

## Directory Layout

```text
fabric-gsd-demo/
├── docs/                 # GSD intent, architecture, runbook, and references
├── fabric-src/           # Active Fabric item definitions committed to Git
├── fabric-export/        # Exported workspace snapshots and materialized definitions
├── infra/                # Auxiliary infrastructure scaffold
├── scripts/              # Demo, Fabric, and validation automation
├── src/                  # Python package placeholder
├── tests/                # Pytest repo-structure checks
├── .github/              # Workflows, instructions, and GSD core assets
└── deployment.parameters.json  # Environment token replacement mapping
```

## Directory Purposes

**`docs/`:**
- Purpose: Present the demo story and supporting references.
- Contains: GSD state/context/plan, architecture, runbook, GitHub setup, references.
- Key files: `docs/gsd/STATE.md`, `docs/gsd/CONTEXT.md`, `docs/gsd/PLAN.md`, `docs/demo/RUNBOOK.md`

**`fabric-src/`:**
- Purpose: Store the current committed Fabric item definitions.
- Contains: item folders with `.platform`, metadata JSON, and notebook source.
- Key files: `fabric-src/lakehouse_fabricgsd_dev_001.Lakehouse/.platform`, `fabric-src/nb_fabricgsd_dev_weu_001.Notebook/notebook-content.py`

**`fabric-export/`:**
- Purpose: Hold exported workspace snapshots and raw API responses.
- Contains: exported workspace item lists and materialized definition folders.
- Key files: `fabric-export/workspace-items.json`, `fabric-export/bulk-export-response.json`

**`infra/`:**
- Purpose: Auxiliary, non-Fabric infrastructure placeholder.
- Contains: Bicep stub.
- Key files: `infra/bicep/main.bicep`

**`scripts/`:**
- Purpose: Demo runner scripts, Fabric API helpers, and validation gate.
- Contains: PowerShell scripts for prerequisites, GSD demo narration, GitHub publish, export, deployment, and repo validation.
- Key files: `scripts/demo/00-prereqs.ps1`, `scripts/demo/01-gsd-to-fabric.ps1`, `scripts/fabric/deploy-bulk-import.ps1`, `scripts/validation/validate-repo.ps1`

**`src/`:**
- Purpose: Placeholder Python package area.
- Contains: empty `fabricops/` directory in the current tree.
- Key files: none detected.

**`tests/`:**
- Purpose: Structural regression tests for the repo shape.
- Contains: pytest checks for GSD docs, item folders, and sample env conventions.
- Key files: `tests/test_repo_structure.py`

**`.github/`:**
- Purpose: Automation, repo instructions, and GSD core support files.
- Contains: workflow files and GSD instruction assets.
- Key files: `.github/workflows/validate.yml`, `.github/workflows/deploy-test.yml`

## Key File Locations

**Entry Points:**
- `scripts/demo/00-prereqs.ps1`: checks tool availability.
- `scripts/demo/01-gsd-to-fabric.ps1`: narrates the demo flow.
- `scripts/demo/02-publish-to-github.ps1`: creates and publishes the repo.

**Configuration:**
- `.env.sample`: environment variable template.
- `deployment.parameters.json`: workspace and resource replacement mapping.
- `.github/workflows/*.yml`: CI and deployment automation.

**Core Logic:**
- `scripts/validation/validate-repo.ps1`: repo structure validation.
- `scripts/fabric/export-workspace.ps1`: export current workspace definitions.
- `scripts/fabric/deploy-bulk-import.ps1`: import definitions into a target workspace.

**Testing:**
- `tests/test_repo_structure.py`: ensures required docs and item folder invariants.

## Naming Conventions

**Files:**
- Fabric item directories use `<DisplayName>.<ItemType>` such as `lakehouse_fabricgsd_dev_001.Lakehouse`.
- Notebook source lives in `notebook-content.py`.
- Item metadata is stored in `*.metadata.json`, `alm.settings.json`, and `.platform`.

**Directories:**
- Demo and validation scripts are grouped by purpose under `scripts/demo/`, `scripts/fabric/`, and `scripts/validation/`.
- Documentation is grouped by narrative and phase under `docs/`.

## Where to Add New Code

**New Feature:**
- Primary code: `scripts/fabric/` for deployment/export changes, or `fabric-src/<NewItem>.<ItemType>/` for new demo items.
- Tests: `tests/test_repo_structure.py` for repository invariants, plus any new pytest module under `tests/`.

**New Component/Module:**
- Implementation: `src/fabricops/` if a Python helper module is introduced, or a new subfolder under `scripts/` if PowerShell remains the driver.

**Utilities:**
- Shared helpers: `scripts/fabric/` for Fabric API utilities and `scripts/validation/` for repo checks.

## Special Directories

**`fabric-src.backup/`:**
- Purpose: Preserved alternate/demo item tree with fuller Fabric examples.
- Generated: Not established by code in this repo.
- Committed: Yes.

**`.github/`:**
- Purpose: Repository automation and GSD assets.
- Generated: No.
- Committed: Yes.

---

*Structure analysis: 2026-06-26*