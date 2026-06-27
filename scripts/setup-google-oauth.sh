#!/usr/bin/env bash
# Google OAuth setup checklist for crm.lomi.africa
# Run manually in Google Cloud Console (requires lomi.africa Workspace admin).

set -euo pipefail

cat <<'EOF'
Google OAuth setup for Twenty CRM (@lomi.africa only)

1. Open https://console.cloud.google.com/apis/credentials
2. OAuth consent screen → User type: Internal
3. Create OAuth 2.0 Client ID → Web application
   - Authorized JavaScript origins:
     https://api.crm.lomi.africa
   - Authorized redirect URIs:
     https://api.crm.lomi.africa/auth/google/callback
4. Copy Client ID and Client Secret, then run:

   railway variable set \
     AUTH_GOOGLE_ENABLED=true \
     AUTH_GOOGLE_CLIENT_ID=<client-id> \
     AUTH_GOOGLE_CLIENT_SECRET=<client-secret> \
     AUTH_GOOGLE_CALLBACK_URL=https://api.crm.lomi.africa/auth/google/callback \
     --service crm-server

   railway variable set AUTH_GOOGLE_ENABLED=true --service crm-worker

Internal consent screen limits sign-in to your Google Workspace.
The server also rejects non-@lomi.africa emails in google.auth.strategy.ts.
EOF
