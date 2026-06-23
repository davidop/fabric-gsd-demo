# GSD Plan

## Phase 1 - Frame the problem

- Show current manual Fabric workflow.
- Explain why clicking does not scale.
- Introduce Fabric item definitions and Git.

## Phase 2 - Spec-driven setup

- Open `docs/gsd/STATE.md`.
- Capture requirement: Contoso sales analytics platform.
- Show how Copilot uses repo instructions.

## Phase 3 - Generate Fabric assets

- Inspect `fabric-src/`.
- Add or modify one item using Copilot.
- Keep environment-specific values out of definitions.

## Phase 4 - Validate

- Run `scripts/validation/validate-repo.ps1`.
- Show validation failures if `.platform` or naming convention is broken.

## Phase 5 - Deploy

- Run dry-run first.
- Explain real deployment prerequisites.
- Optional: run real Bulk Import to target workspace.

## Phase 6 - Verify and ship

- Verify item list in target workspace.
- Tag release.
- Explain PR review and promotion model.
