# Fabric as Code GSD Roadmap

## Phase 1: Stabilize Demo (In Progress)

**Goal:** Stabilize the existing demo without deploying to Fabric. Establish GSD operational pattern and local validation.

**Duration:** Event day or before

**Deliverables:**
- ✅ Complete notebook transformation logic (Revenue, Cost, Margin, MarginPercentage)
- ✅ Update documentation (names, references)
- ✅ Validate repo structure (`.platform`, naming conventions)
- ✅ Dry-run deployment (safe, repeatable)
- ✅ All GSD artifacts (PROJECT.md, ROADMAP.md, REQUIREMENTS.md, STATE.md)

**Success Criteria:**
- `scripts/validation/validate-repo.ps1` passes
- `scripts/fabric/deploy-bulk-import.ps1 -DryRun` completes without errors
- RUNBOOK.md executable end-to-end
- No hardcoded GUIDs or secrets in code

**Next:** Phase 2

---

## Phase 2: Expand Fabric Assets (Planned)

**Goal:** Add semantic model and report items. Demonstrate multi-item coordination.

**Planned Items:**
- `SalesModel.SemanticModel` (DAX measures, relationships)
- `SalesReport.Report` (Power BI visual consuming semantic model)

**Scope:** Design contracts (UI-SPEC.md for report, AI-SPEC.md for semantic model logic)

---

## Phase 3: GitHub Actions CI/CD (Planned)

**Goal:** Automate validation and coordinate multi-workspace promotion.

**Scope:**
- Validation workflow (runs `validate-repo.ps1` on PR)
- Deployment workflow (manual trigger, dry-run → real deployment)
- Artifact tracking

---

## Phase 4: Real Fabric Deployment (Planned)

**Goal:** Demonstrate end-to-end promotion through Fabric workspaces.

**Scope:**
- Dev workspace (development and testing)
- Test workspace (staging before production)
- Production promotion gate

---

## Phase 5: Observability & Monitoring (Future)

**Goal:** Add production health checks and cost tracking.

**Scope:** Application Insights, cost alerts, data freshness monitoring
