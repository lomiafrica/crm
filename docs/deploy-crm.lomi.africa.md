# Deploy Twenty CRM to crm.lomi.africa

## Architecture

- **Frontend:** Vercel → `https://crm.lomi.africa`
- **API + worker + DB:** Railway project `lomi-crm`
  - `crm-server` → `https://api.crm.lomi.africa`
  - `crm-worker` → background jobs
  - `Postgres` → primary database
  - `Redis` → cache / queues

## CI deploy (recommended)

Pushes to `main` on **lomiafrica/crm** run [`.github/workflows/deploy-lomi-production.yaml`](.github/workflows/deploy-lomi-production.yaml):

1. Deploy `crm-server` to Railway
2. Deploy `crm-worker` to Railway
3. Deploy frontend to Vercel

### One-time GitHub secrets (lomiafrica/crm → Settings → Secrets)

| Secret | How to get it |
|--------|----------------|
| `RAILWAY_TOKEN` | Railway → project **lomi-crm** → Settings → Tokens → Create |
| `VERCEL_TOKEN` | [vercel.com/account/tokens](https://vercel.com/account/tokens) |
| `VERCEL_ORG_ID` | Vercel → Team Settings → General |
| `VERCEL_PROJECT_ID_CRM` | Create Vercel project for this repo, copy Project ID |

**Tip:** Disable Railway's native GitHub auto-deploy on `crm-server` and `crm-worker` (Settings → Source → Disconnect) so only CI triggers builds.

Manual deploy fallback: `workflow_dispatch` on the workflow, or `railway up -s crm-server`.


Project: **lomi-crm** (`b931934c-995c-4f3c-9587-09c71940c2f0`)

Services:
- `crm-server` — API (`railway.toml`, start: `node dist/main`)
- `crm-worker` — worker (`railway.worker.toml`, start: `yarn worker:prod`)
- `Postgres`
- `Redis`

Temporary API URL (until custom domain): `https://crm-server-production-4904.up.railway.app`

### Link locally

```bash
cd apps/crm
railway link -p lomi-crm
railway service link crm-server
```

### Deploy server

```bash
railway up -d -s crm-server -y
```

### Deploy worker

In Railway dashboard → `crm-worker` → Settings → Deploy → set **Custom Start Command** to `yarn worker:prod`, then:

```bash
railway service link crm-worker
railway up -d -s crm-worker -y
```

Or copy `railway.worker.toml` to `railway.toml` before deploying the worker.

### Custom API domain

```bash
railway domain api.crm.lomi.africa --service crm-server --port 3000
```

Add the returned CNAME at your DNS provider for `api.crm`.

## Google OAuth (@lomi.africa only)

**Full walkthrough:** [docs/google-oauth-setup.md](google-oauth-setup.md)

Quick version: Google Cloud → Internal OAuth app → add callback `https://api.crm.lomi.africa/auth/google/callback` → set Railway vars on `crm-server` and `crm-worker`.

## Vercel (frontend)

1. `vercel login`
2. From repo root, create project:

```bash
cd apps/crm
vercel --cwd . \
  --build-env REACT_APP_SERVER_BASE_URL=https://api.crm.lomi.africa
```

Project settings:
- **Root Directory:** `apps/crm`
- **Build Command:** `yarn nx build twenty-front`
- **Output Directory:** `packages/twenty-front/dist`
- **Environment variable:** `REACT_APP_SERVER_BASE_URL=https://api.crm.lomi.africa`

3. Add domain `crm.lomi.africa` in Vercel → Domains

## DNS

| Type  | Name                | Target / Value |
|-------|---------------------|----------------|
| CNAME | `crm`               | `cname.vercel-dns.com` |
| CNAME | `api.crm`           | `v3xhxaqw.up.railway.app` |
| TXT   | `_railway-verify.api.crm` | `railway-verify=adfa0b26b753ee573c89c7c6846237896201c48c5bde67a2c1d5cfbcc0b1f162` |

Check propagation:

```bash
railway domain status api.crm.lomi.africa --service crm-server
```

## First run

1. Ensure Google OAuth is enabled and server healthcheck passes (`/healthz`)
2. Open `https://crm.lomi.africa`
3. Sign in with Google using an `@lomi.africa` account
4. Create workspace **lomi**
5. Invite staff from Settings → Members
