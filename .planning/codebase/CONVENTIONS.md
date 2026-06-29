# Coding Conventions

**Analysis Date:** 2026-06-26

## Naming Patterns

**Files:**
- Fabric item folders use `<name>.<ItemType>` and metadata files use Fabric-standard names such as `.platform`, `alm.settings.json`, and `lakehouse.metadata.json`.
- PowerShell scripts are named by workflow step, such as `00-prereqs.ps1` and `deploy-bulk-import.ps1`.

**Functions:**
- PowerShell helper functions use PascalCase, such as `Build-BulkImportPayload`.
- Script entry points are parameterized with `param(...)` blocks.

**Variables:**
- PowerShell variables use `$PascalCase` or `$camelCase` depending on scope; repository scripts prefer readable, descriptive names like `$ItemRoot`, `$TargetWorkspaceId`, and `$definitionParts`.

**Types:**
- JSON object shapes are described implicitly through Fabric metadata rather than explicit code types.

## Code Style

**Formatting:**
- PowerShell formatting is conventional and indentation-based.
- Markdown is used for narrative docs and runbooks.
- JSON files are kept machine-readable and human-reviewable.

**Linting:**
- No repo-specific linting configuration was detected for PowerShell or Python.
- Structural validation is enforced through scripts and pytest.

## Import Organization

**Order:**
1. PowerShell `param(...)` block.
2. `$ErrorActionPreference` and other runtime configuration.
3. Core operational logic and helper functions.

**Path Aliases:**
- Not detected.

## Error Handling

**Patterns:**
- Scripts set `$ErrorActionPreference = "Stop"` when they perform validation or deployment work.
- Validation accumulates failures and exits non-zero after printing them.
- Long-running REST operations are polled and fail on unexpected terminal statuses.

## Logging

**Framework:**
- PowerShell console output.

**Patterns:**
- `Write-Host` is used for progress and user guidance.
- `Write-Warning` appears in prereq discovery.
- CI logs are the primary non-interactive output in GitHub Actions.

## Comments

**When to Comment:**
- Comments are used sparingly to explain API caveats, especially around Fabric bulk import/export payload shape and long-running operations.

**JSDoc/TSDoc:**
- Not detected.

## Function Design

**Size:**
- Functions are small and single-purpose; most scripts keep orchestration at the top level.

**Parameters:**
- Scripts use explicit parameters with environment-variable defaults for secrets and workspace IDs.

**Return Values:**
- PowerShell helpers return raw access tokens or emit JSON/text to stdout for downstream steps.

## Module Design

**Exports:**
- Not applicable in the current tree; the repo does not expose a formal reusable module surface.

**Barrel Files:**
- Not detected.

---

*Convention analysis: 2026-06-26*