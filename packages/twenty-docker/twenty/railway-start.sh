#!/bin/sh
set -e

if [ "${RAILWAY_SERVICE_NAME}" = "crm-worker" ]; then
  exec yarn worker:prod
fi

exec node dist/main
