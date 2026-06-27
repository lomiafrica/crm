# Deploy Twenty CRM to crm.lomi.africa

## Architecture

- **Frontend:** Vercel → `https://crm.lomi.africa`
- **API + worker + DB:** Railway project `lomi-crm`
  - `crm-server` → `https://api.crm.lomi.africa`
  - `crm-worker` → background jobs
  - `Postgres` → primary database
  - `Redis` → cache / queues

## Railway (already provisioned)

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

## Google OAuth (Internal — @lomi.africa only)

1. [Google Cloud Console](https://console.cloud.google.com) → APIs & Services → OAuth consent screen
2. **User type:** Internal (limits sign-in to your Google Workspace domain)
3. Create **OAuth 2.0 Client ID** (Web application):
   - **Authorized JavaScript origins:** `https://api.crm.lomi.africa`
   - **Authorized redirect URIs:** `https://api.crm.lomi.africa/auth/google/callback`
4. Set Railway variables on `crm-server` and `crm-worker`:

```bash
railway variable set \
  AUTH_GOOGLE_ENABLED=true \
  AUTH_GOOGLE_CLIENT_ID=<client-id> \
  AUTH_GOOGLE_CLIENT_SECRET=<client-secret> \
  AUTH_GOOGLE_CALLBACK_URL=https://api.crm.lomi.africa/auth/google/callback \
  --service crm-server

railway variable set AUTH_GOOGLE_ENABLED=true --service crm-worker
```

Code enforces `@lomi.africa` in `google.auth.strategy.ts` as defense-in-depth.

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

| Type  | Name     | Target                                      |
|-------|----------|---------------------------------------------|
| CNAME | `crm`    | `cname.vercel-dns.com`                      |
| CNAME | `api.crm`| Railway-provided host for `api.crm.lomi.africa` |

## First run

1. Ensure Google OAuth is enabled and server healthcheck passes (`/healthz`)
2. Open `https://crm.lomi.africa`
3. Sign in with Google using an `@lomi.africa` account
4. Create workspace **lomi**
5. Invite staff from Settings → Members
