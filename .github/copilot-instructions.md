# Copilot instructions - Fabric as Code with GSD

You are assisting with a Microsoft Fabric as Code demo.

Follow these rules:

1. Treat `docs/gsd/STATE.md`, `docs/gsd/CONTEXT.md` and `docs/gsd/PLAN.md` as the source of intent.
2. Do not generate isolated JSON. Always update README/runbooks/tests when changing Fabric definitions.
3. Preserve the repo conventions:
   - Fabric items live under `fabric-src/<Name>.<ItemType>/`.
   - Every item folder must include `.platform`.
   - Deployment parameters live under `deployment.parameters.json`.
4. Prefer PowerShell for demo scripts because the session is Microsoft-oriented.
5. Never hardcode tenant IDs, workspace IDs, secrets, GUIDs or connection strings.
6. When unsure about a Fabric item schema, create a safe placeholder and add a TODO in `docs/gsd/STATE.md` instead of inventing production-ready schemas.
7. Every demo step must support dry-run mode.

Narrative to preserve:

Spec → Plan → Code → Validate → Pull Request → Deploy → Verify
