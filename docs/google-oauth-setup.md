# Google sign-in for crm.lomi.africa

You only need this if you want staff to log in with their **@lomi.africa Google account** (no passwords).

**Who can do this:** someone with **Google Workspace admin** access for `lomi.africa`.

**Time:** ~10 minutes.

---

## What you're creating

A private Google login button that only works for `@lomi.africa` emails. Two layers enforce that:

1. **Google "Internal" app** — Google blocks anyone outside your Workspace
2. **Server code** — rejects any email that isn't `@lomi.africa`

---

## Step 1 — Open Google Cloud

1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. Sign in with your **@lomi.africa** admin account
3. Top bar → pick a project (or **New Project** → name it `lomi-crm` → Create)

---

## Step 2 — OAuth consent screen (Internal)

1. Left menu → **APIs & Services** → **OAuth consent screen**
2. **User type** → choose **Internal** → Create  
   *(If you don't see Internal, your account isn't a Workspace admin — ask whoever manages lomi.africa email.)*
3. Fill in:
   - **App name:** `lomi CRM`
   - **User support email:** your @lomi.africa email
   - **Developer contact:** your @lomi.africa email
4. Save through the screens (no scopes needed for basic login)

---

## Step 3 — Create OAuth credentials

1. **APIs & Services** → **Credentials** → **+ Create credentials** → **OAuth client ID**
2. Application type: **Web application**
3. Name: `lomi CRM production`
4. **Authorized JavaScript origins** — add:
   ```
   https://api.crm.lomi.africa
   ```
5. **Authorized redirect URIs** — add:
   ```
   https://api.crm.lomi.africa/auth/google/callback
   ```
6. Click **Create**
7. Copy the **Client ID** and **Client secret** (you'll need both in the next step)

---

## Step 4 — Add credentials to Railway

From your machine (with Railway CLI linked to `lomi-crm`):

```bash
cd apps/crm

railway variable set \
  AUTH_GOOGLE_ENABLED=true \
  AUTH_GOOGLE_CLIENT_ID="paste-client-id-here" \
  AUTH_GOOGLE_CLIENT_SECRET="paste-client-secret-here" \
  AUTH_GOOGLE_CALLBACK_URL=https://api.crm.lomi.africa/auth/google/callback \
  --service crm-server

railway variable set AUTH_GOOGLE_ENABLED=true --service crm-worker
```

Railway will redeploy automatically. Wait ~2 minutes.

---

## Step 5 — Test

1. Open [https://crm.lomi.africa](https://crm.lomi.africa) *(after Vercel + DNS are live)*
2. Click **Continue with Google**
3. Sign in with an `@lomi.africa` account
4. Create your workspace (first user becomes admin)

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| "Access blocked" / can't pick Internal | You need Workspace admin, not just a @lomi.africa mailbox |
| Redirect URI mismatch | Double-check the callback URL is exactly `https://api.crm.lomi.africa/auth/google/callback` |
| Login works but wrong domain | Only @lomi.africa accounts are allowed by design |
| No Google button on login page | `AUTH_GOOGLE_ENABLED` must be `true` on `crm-server` |

---

## Optional — store credentials in GitHub instead

If you prefer secrets in GitHub (for a future automated setup), add these to **lomiafrica/crm** → Settings → Secrets:

- `AUTH_GOOGLE_CLIENT_ID`
- `AUTH_GOOGLE_CLIENT_SECRET`

Then run the Railway commands above once, or ask engineering to wire a setup workflow.
