# GitHub Actions

Upstream Twenty CI/CD workflows were removed from this fork.

Deployments for lomi. CRM (if used) are handled from the monorepo workflow
`app-deploy-crm.yml` via manual `workflow_dispatch` / `repository_dispatch`.

**Do not use GitHub "Sync fork"** (or merge `twentyhq/twenty` into `main`).
That replaces lomi. OAuth/deploy commits with upstream Twenty history.
If `main` is overwritten again, restore from `backup/lomi-main-pre-restore-2026-07-23`
(Twenty tip kept at `backup/twenty-synced-main-2026-07-23`).
