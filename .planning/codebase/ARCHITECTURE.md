<!-- refreshed: 2026-06-26 -->
# Architecture

**Analysis Date:** 2026-06-26

## System Overview

```text
┌─────────────────────────────────────────────────────────────┐
│                     Demo Intent Layer                       │
├──────────────────┬──────────────────┬───────────────────────┤
│   GSD docs       │   README / runbook│   GitHub Actions      │
│ `docs/gsd/*`     │ `README.md`      │ `.github/workflows/*`  │
└────────┬─────────┴────────┬─────────┴──────────┬────────────┘
         │                  │                     │
         ▼                  ▼                     ▼
┌─────────────────────────────────────────────────────────────┐
│                 Repo Orchestration Layer                    │
│ `scripts/demo/*`  `scripts/validation/*`  `scripts/fabric/*`│
└────────┬──────────────────────────┬─────────────────────────┘
         │                          │
         ▼                          ▼
┌────────────────────────────┐   ┌────────────────────────────┐
│ Fabric item definitions    │   │ Auxiliary infra scaffold    │
│ `fabric-src/`              │   │ `infra/bicep/main.bicep`    │
└────────┬───────────────────┘   └────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│ Microsoft Fabric REST APIs / target workspace               │
└─────────────────────────────────────────────────────────────┘
```

## Component Responsibilities

| Component | Responsibility | File |
|-----------|----------------|------|
| GSD intent docs | Capture scenario, constraints, and demo plan | `docs/gsd/STATE.md`, `docs/gsd/CONTEXT.md`, `docs/gsd/PLAN.md` |
| Demo runbook | Provide presenter steps and fallback path | `docs/demo/RUNBOOK.md` |
| Validation gate | Enforce minimal repo conventions before deploy | `scripts/validation/validate-repo.ps1` |
| Fabric export/import | Move definitions between workspace and repo | `scripts/fabric/export-workspace.ps1`, `scripts/fabric/deploy-bulk-import.ps1` |
| Fabric item store | Hold committed definitions and metadata | `fabric-src/` |
| CI pipelines | Run validation and optional test deployment | `.github/workflows/validate.yml`, `.github/workflows/deploy-test.yml` |

## Pattern Overview

**Overall:** Spec-driven demo orchestration around a file-based Fabric item definition repository.

**Key Characteristics:**
- The repo stores Fabric item folders as the deployable unit rather than generated application source.
- Validation is intentionally shallow and structural, centered on folder naming and `.platform` presence.
- Deployment is mediated through PowerShell wrappers over Fabric REST APIs, with dry-run support.

## Layers

**Intent and documentation:**
- Purpose: Provide the business story, GSD context, and presenter guidance.
- Location: `docs/gsd/`, `docs/demo/`, `README.md`
- Contains: scenario docs, runbooks, architecture notes.
- Depends on: none.
- Used by: demo scripts and human presenters.

**Orchestration scripts:**
- Purpose: Validate, export, and promote Fabric item folders.
- Location: `scripts/demo/`, `scripts/fabric/`, `scripts/validation/`
- Contains: PowerShell entry points and helper functions.
- Depends on: Fabric REST APIs, Entra token endpoint, GitHub CLI.
- Used by: local operators and GitHub Actions.

**Fabric definition store:**
- Purpose: Persist deployable Fabric item definitions in Git.
- Location: `fabric-src/`, `fabric-export/`
- Contains: `.platform`, metadata JSON, notebook source, and export snapshots.
- Depends on: Fabric item schema conventions.
- Used by: validation and bulk import scripts.

**Auxiliary infrastructure:**
- Purpose: Placeholder for non-Fabric resources needed by the demo.
- Location: `infra/bicep/main.bicep`
- Contains: documentation-only note and output.
- Depends on: Azure Resource Group location only.
- Used by: no current deployment path.

## Data Flow

### Primary Request Path

1. Presenter or CI starts from the GSD docs and demo runbook (`docs/gsd/STATE.md`, `docs/demo/RUNBOOK.md`).
2. Validation runs structural checks against `fabric-src/` (`scripts/validation/validate-repo.ps1`).
3. Deployment script optionally acquires an Entra token and calls the Fabric bulk import endpoint (`scripts/fabric/deploy-bulk-import.ps1`, `scripts/fabric/Get-FabricAccessToken.ps1`).

### Export and Rehydrate Flow

1. Source workspace items are listed through the Fabric API (`scripts/fabric/export-workspace.ps1`).
2. Bulk export returns base64 payload parts, which are written back to `fabric-export/definitions/`.
3. The exported definition folders can be copied into `fabric-src/` for Git-based promotion.

**State Management:**
- The committed source of truth is the folder structure under `fabric-src/`.
- Runtime secrets and workspace IDs remain outside the repo in environment variables or secret stores.

## Key Abstractions

**Fabric item folder:**
- Purpose: One deployable item per directory.
- Examples: `fabric-src/lakehouse_fabricgsd_dev_001.Lakehouse/`, `fabric-src/nb_fabricgsd_dev_weu_001.Notebook/`
- Pattern: Folder name ends with the item type, and `.platform` declares type and display name.

**Bulk import payload:**
- Purpose: Promote a collection of definition files to a Fabric workspace.
- Examples: `scripts/fabric/deploy-bulk-import.ps1`
- Pattern: Recursively collects files under each item folder and sends them as base64 parts.

**Repo validation gate:**
- Purpose: Catch structure drift before promotion.
- Examples: `scripts/validation/validate-repo.ps1`, `tests/test_repo_structure.py`
- Pattern: Folder-name regex, `.platform` JSON validation, and required file presence checks.

## Entry Points

**Demo start:**
- Location: `scripts/demo/00-prereqs.ps1`
- Triggers: Presenter or operator.
- Responsibilities: Check tool availability.

**GSD to Fabric demo:**
- Location: `scripts/demo/01-gsd-to-fabric.ps1`
- Triggers: Presenter during the story sequence.
- Responsibilities: Display the demo narrative and repo item folders.

**GitHub publish helper:**
- Location: `scripts/demo/02-publish-to-github.ps1`
- Triggers: Manual repo bootstrap.
- Responsibilities: Create a GitHub repository and push the branch.

## Architectural Constraints

- **Threading:** Single-script execution model; no application-level concurrency is present.
- **Global state:** Secrets, workspace IDs, and item roots are supplied via environment variables; no mutable in-memory singleton state is modeled.
- **Circular imports:** Not applicable.
- **Schema drift:** Fabric item definitions may change by tenant/version, so the repo treats exported definitions as the authoritative shape.

## Anti-Patterns

### Hardcoding environment-specific IDs

**What happens:** Workspace and client identifiers are embedded in runtime code or definitions.
**Why it's wrong:** It breaks portability between dev, test, and demo environments.
**Do this instead:** Use `deployment.parameters.json`, environment variables, and token replacement placeholders.

### Treating the demo tree as production schema

**What happens:** Placeholder Fabric definitions are assumed to be a complete production-ready implementation.
**Why it's wrong:** The active `fabric-src/` tree only contains illustrative lakehouse and notebook assets.
**Do this instead:** Export live definitions with `scripts/fabric/export-workspace.ps1` before promoting the demo to a real workspace.

## Error Handling

**Strategy:** Fail fast on structural validation, and surface API errors directly in PowerShell output.

**Patterns:**
- Validation failures are accumulated and printed before a non-zero exit in `scripts/validation/validate-repo.ps1`.
- Bulk import/export scripts poll long-running Fabric operations and throw on unexpected statuses.

## Cross-Cutting Concerns

**Logging:** PowerShell `Write-Host` / `Write-Warning` plus GitHub Actions job logs.
**Validation:** Script-based structural checks and pytest coverage for repository invariants.
**Authentication:** Entra ID client-credential flow for Fabric API access.

---

*Architecture analysis: 2026-06-26*