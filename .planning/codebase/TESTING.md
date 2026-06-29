# Testing Patterns

**Analysis Date:** 2026-06-26

## Test Framework

**Runner:**
- pytest 8.2.2
- Config: `requirements.txt` and `.github/workflows/validate.yml`

**Assertion Library:**
- pytest `assert`

**Run Commands:**
```bash
pytest -q
python -m pytest -q
./scripts/validation/validate-repo.ps1
```

## Test File Organization

**Location:**
- Co-located repository-level tests in `tests/`.

**Naming:**
- Test files use `test_*.py` naming.

**Structure:**
```text
tests/
└── test_repo_structure.py
```

## Test Structure

**Suite Organization:**
```python
def test_gsd_docs_exist():
    assert (ROOT / "docs/gsd/STATE.md").exists()
    assert (ROOT / "docs/gsd/CONTEXT.md").exists()
    assert (ROOT / "docs/gsd/PLAN.md").exists()


def test_fabric_item_folders_have_platform():
    item_root = ROOT / "fabric-src"
    folders = [p for p in item_root.iterdir() if p.is_dir()]
    assert folders, "No Fabric item folders found"
    for folder in folders:
        assert (folder / ".platform").exists(), f"Missing .platform in {folder.name}"
```

**Patterns:**
- Tests are filesystem assertions rather than behavior-driven app tests.
- The suite validates repo invariants that mirror the PowerShell validation gate.

## Mocking

**Framework:**
- None detected.

**Patterns:**
```python
assert (ROOT / "deployment.parameters.json").exists()
```

**What to Mock:**
- Not applicable in the current test surface.

**What NOT to Mock:**
- The repository layout itself; tests read the real filesystem.

## Fixtures and Factories

**Test Data:**
- The repository tree is the fixture.

**Location:**
- No separate fixture directory detected.

## Coverage

**Requirements:**
- No explicit numeric coverage target detected.

**View Coverage:**
```bash
pytest --cov
```

## Test Types

**Unit Tests:**
- Not detected.

**Integration Tests:**
- GitHub Actions executes repo validation and pytest together in `.github/workflows/validate.yml`.

**E2E Tests:**
- Not detected.

## Common Patterns

**Async Testing:**
- Not detected.

**Error Testing:**
```python
assert (ROOT / "docs/gsd/STATE.md").exists()
```

---

*Testing analysis: 2026-06-26*