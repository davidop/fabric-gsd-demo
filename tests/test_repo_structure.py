from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


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


def test_no_secrets_in_sample_env():
    env = (ROOT / ".env.sample").read_text()
    assert "CLIENT_SECRET=" in env
    assert "FABRIC_CLIENT_SECRET=\n" in env
