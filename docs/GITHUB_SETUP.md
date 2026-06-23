# Publish to GitHub

## Option A - GitHub CLI

```bash
gh repo create davidnumber/stop-clicking-fabric-as-code-gsd --public --source=. --remote=origin --push
```

## Option B - Manual

1. Create an empty repository in GitHub.
2. Run:

```bash
git remote add origin https://github.com/<owner>/stop-clicking-fabric-as-code-gsd.git
git branch -M main
git push -u origin main
```

## GitHub Actions secrets

Create these repository secrets before running real deployment:

- `FABRIC_TENANT_ID`
- `FABRIC_CLIENT_ID`
- `FABRIC_CLIENT_SECRET`
- `FABRIC_TARGET_WORKSPACE_ID`

## First recommended PR

Before the event, create a PR that replaces the illustrative sample folders under `fabric-src/` with definitions exported from your real Fabric Dev workspace.
