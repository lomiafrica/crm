#!/bin/sh
set -e

if [ "${RAILWAY_SERVICE_NAME}" = "crm-worker" ]; then
  exec yarn worker:prod
fi

# Railway startCommand replaces Docker CMD and does not invoke ENTRYPOINT.
# Run migrations explicitly before starting the API.
if [ "${DISABLE_DB_MIGRATIONS}" != "true" ]; then
  DISABLE_CRON_JOBS_REGISTRATION=true /app/entrypoint.sh /bin/true
fi

exec node dist/main
