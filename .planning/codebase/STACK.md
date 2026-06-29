# Technology Stack

**Analysis Date:** 2026-06-26

## Languages

**Primary:**
- PowerShell 7+ - Demo, validation, export/import, and deployment scripts in `scripts/demo/`, `scripts/fabric/`, and `scripts/validation/`.
- Markdown - Repository documentation in `docs/`, `README.md`, and Fabric item READMEs.

**Secondary:**
- Python 3.11+ - Test runner dependencies and any Python-based helpers referenced by `requirements.txt` and `.github/workflows/validate.yml`.
- JSON - Fabric item metadata, workflow definitions, and deployment parameter files in `fabric-src/`, `fabric-export/`, and `deployment.parameters.json`.
- Bicep - Auxiliary infrastructure scaffold in `infra/bicep/main.bicep`.

## Runtime

**Environment:**
- Microsoft Fabric as the target platform for item definitions and workspace promotion.
- Linux dev container for repository work, with PowerShell, Azure CLI, Python, Git, and Node available in the workspace.

**Package Manager:**
- pip - Python dependencies in `requirements.txt`.
- Lockfile: missing.

## Frameworks

**Core:**
- Microsoft Fabric Item Definitions - Deployable artifact model for Lakehouse, Notebook, DataPipeline, SemanticModel, and Report items.
- GitHub Actions - Validation and test automation in `.github/workflows/validate.yml` and `.github/workflows/deploy-test.yml`.

**Testing:**
- pytest 8.2.2 - Repository structure tests in `tests/test_repo_structure.py`.

**Build/Dev:**
- PowerShell scripts - Local demo orchestration, validation, export, and bulk import deployment.
- Azure CLI - Prerequisite only; no direct Azure resource provisioning flow is modeled for the Fabric demo.

## Key Dependencies

**Critical:**
- pytest - Runs the repository structure checks wired into CI.
- requests - Present in `requirements.txt`; no direct Python application code currently uses it in `src/fabricops/`.
- pyyaml - Present in `requirements.txt`; no active Python module in the current tree uses it.

**Infrastructure:**
- Azure CLI - Mentioned as a prerequisite in the demo runbook and prereq script.
- GitHub CLI - Used by `scripts/demo/02-publish-to-github.ps1` for repo creation.

## Configuration

**Environment:**
- `.env.sample` documents required Fabric and workspace IDs.
- `deployment.parameters.json` maps environment-specific IDs with token replacement placeholders.
- `docs/GITHUB_SETUP.md` and the demo scripts assume service-principal-based Fabric API access.

**Build:**
- `.github/workflows/validate.yml` - PR and main validation.
- `.github/workflows/deploy-test.yml` - Manual deployment gate with dry-run support.
- `infra/bicep/main.bicep` - Auxiliary placeholder for non-Fabric resources.

## Platform Requirements

**Development:**
- PowerShell 7+ for all demo scripts.
- Python 3.11+ for pytest execution.
- Git and Azure CLI installed in the local environment.

**Production:**
- Microsoft Fabric tenant with API access, service principal permissions, and target workspaces for promotion.

---

*Stack analysis: 2026-06-26*