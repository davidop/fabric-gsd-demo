# Project: Stop Clicking — Fabric as Code with GSD

## Session

**Stop Clicking: domina Microsoft Fabric con Fabric as Code, Copilot y GSD**

Global Fabric Day 2026, Madrid

## Vision

Transform Microsoft Fabric workspace management from manual clicking to a spec-driven, version-controlled, automated workflow using:

- **GSD** — governance layer (intent, context, decisions, planning, verification)
- **Fabric Item Definitions** — deployable artifacts (versioned in Git)
- **GitHub Copilot / agents** — acceleration (generation, maintenance)
- **GitHub Actions** — CI/CD (validation, orchestration)
- **Fabric REST APIs / Bulk Import** — promotion (dry-run + real deployment)

## Core Message

GSD does not replace Fabric Item Definitions.

```
Intent + Context + Plan + Validation + Deployment = Fabric as Code
```

GSD provides the operating model. Fabric provides the deployable artifacts.

## Project Scope

### In Scope

- Demo-ready Fabric workspace as code (2+ items, versioned in Git)
- GSD operational workflow (discuss → plan → execute → verify → ship)
- Local validation gate (PowerShell conventions checker)
- Dry-run deployment script (safe for live demo)
- Runbook for event delivery
- GitHub Actions integration (optional Phase 2+)

### Out of Scope

- Production-grade semantic models
- Complete coverage of all Fabric item types
- Native Fabric ALM feature replacement
- Real Fabric workspace deployment (Phase 1)

## Target Audience

- Microsoft customers evaluating Fabric
- Teams building analytical solutions
- DevOps engineers standardizing Fabric deployment

## Key Artifacts

| Artifact | Location | Purpose |
|----------|----------|---------|
| Item Definitions | `fabric-src/` | Versioned, deployable Fabric items |
| Demo Data | `data/raw/sales.csv` | Sample dataset for narrative |
| Validation Gate | `scripts/validation/validate-repo.ps1` | Local conventions check |
| Deployment Script | `scripts/fabric/deploy-bulk-import.ps1` | Dry-run + real deployment |
| Demo Runbook | `docs/demo/RUNBOOK.md` | Event delivery script |
| GSD State | `docs/gsd/STATE.md` | Narrative context |

## Real Fabric Items (Phase 1)

- `lakehouse_fabricgsd_dev_001.Lakehouse` — medallion raw layer
- `nb_fabricgsd_dev_weu_001.Notebook` — data transformation notebook

## Success Criteria (Phase 1)

✅ Notebook compiles and runs (transforms sales.csv)
✅ Validation gate passes (`.platform` metadata, naming conventions)
✅ Dry-run deployment completes without secrets/hardcoded IDs
✅ RUNBOOK.md executed successfully in demo environment
✅ All GSD artifacts (PROJECT, ROADMAP, REQUIREMENTS, STATE) operational

## Next Steps

After Phase 1 stabilization:
- Phase 2: Add semantic model + report items
- Phase 3: GitHub Actions CI/CD validation pipeline
- Phase 4: Real Fabric workspace deployment + verification
