# Operational State: Phase 1

## Current Status

**Phase:** 1 — Stabilize Demo
**Started:** 2026-06-26
**Status:** In Progress

## Checkpoint

### Completed

✅ GSD operational artifacts initialized
- PROJECT.md — project vision and scope
- ROADMAP.md — phased delivery plan
- REQUIREMENTS.md — Phase 1 technical & business requirements
- config.json — workflow preferences
- STATE.md — this file

✅ Existing repo structure validated
- `docs/gsd/` artifacts present and coherent (STATE.md, PLAN.md, CONTEXT.md)
- `fabric-src/` contains real items with `.platform` metadata
- `scripts/validation/` validation gate ready
- `scripts/fabric/` deployment script in dry-run mode
- `data/raw/sales.csv` available

✅ Documentation coherence checked
- RUNBOOK.md uses correct artifact names (lakehouse_fabricgsd_dev_001, nb_fabricgsd_dev_weu_001)
- No references to old placeholder names

### In Progress

⏳ Notebook completion
- Status: Skeleton exists, needs transformation logic
- Task: Add Revenue, Cost, Margin, MarginPercentage calculations
- Blocked by: None (ready to implement)

⏳ Validation gate execution
- Status: Script exists, not yet executed against current state
- Task: Run `scripts/validation/validate-repo.ps1` and fix failures
- Blocked by: None (ready)

⏳ Dry-run deployment verification
- Status: Script exists, not yet tested
- Task: Run `scripts/fabric/deploy-bulk-import.ps1 -DryRun`
- Blocked by: Notebook completion (should complete first)

⏳ RUNBOOK.md walkthrough
- Status: Runbook exists, not yet verified end-to-end
- Task: Execute all demo steps in sequence
- Blocked by: Notebook + validation completion

### Decisions Made

| Decision | Rationale |
|---|---|
| Use existing `lakehouse_*` and `nb_*` item names | Real artifact names already established in repo; renaming would break existing exports and exports |
| Complete notebook inline (Python) | Fabric notebooks native format; simplest integration with Lakehouse |
| Keep dry-run as default in deploy script | Safe for live demo; real deployment optional |
| Validation gate = convention checker | Not a semantic checker; focuses on structure (naming, `.platform`) |
| Use data/raw/sales.csv as demo dataset | Already present, realistic for retail analytics narrative |

## Outstanding Items

### High Priority (blocks Phase 1 completion)

1. **Implement notebook calculations** (15 min)
   - Read sales.csv
   - Calculate Revenue, Cost, Margin, MarginPercentage
   - Write to curated tables
   - Artifact: `fabric-src/nb_fabricgsd_dev_weu_001.Notebook/notebook-content.py`

2. **Run validation gate** (5 min)
   - Execute: `pwsh ./scripts/validation/validate-repo.ps1`
   - Expected: Exit code 0
   - If fails: Fix `.platform` or naming issues

3. **Test dry-run deployment** (5 min)
   - Execute: `pwsh ./scripts/fabric/deploy-bulk-import.ps1 -DryRun`
   - Expected: Completion without errors
   - Verify: No hardcoded secrets in output

### Medium Priority (improves completeness)

4. **Execute full RUNBOOK.md walkthrough** (20 min)
   - Run each demo step
   - Verify: Prerequisites check, validation, dry-run
   - Document: Any manual adjustments needed

5. **Add GitHub Actions workflow** (Phase 2)
   - Trigger on PR: Run validation
   - Trigger on main: Coordinate deployment

## Risks & Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Notebook formula errors (e.g., MarginPercentage when Revenue=0) | Demo failure | Test with edge cases; pre-calculate expected outputs |
| `.platform` schema mismatch across Fabric versions | Validation false-positive | Use latest schema; validate with real Fabric export |
| Hardcoded IDs in deploy script | Security/demo risk | Use `deployment.parameters.json` placeholders; never commit real IDs |
| API rate limits in live demo | Demo hangs | Use `-DryRun` first; have video backup |

## Next Phase Gates

Before Phase 2 (Expand Fabric Assets):
- [ ] AC-1: Validation gate passes
- [ ] AC-2: Dry-run completes successfully
- [ ] AC-3: Notebook executes without errors
- [ ] AC-4: RUNBOOK.md walkthrough successful
- [ ] All acceptance criteria met

## Communications

- Demo: Global Fabric Day 2026, Madrid
- Audience: Microsoft customers, Fabric users
- Key message: GSD + Fabric Item Definitions = spec-driven infrastructure
