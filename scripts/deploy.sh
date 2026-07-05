#!/usr/bin/env bash
# Production deploy — runs ON the server (crypto).
# Pulls latest code, rebuilds the API image, migrates, restarts.
# Invoked manually or by the GitHub Actions deploy workflow.
set -euo pipefail

BASE="${FLIRT_BASE:-/opt/flirt}"
cd "$BASE/Flirt-api" && git pull --ff-only
cd "$BASE/Flirt-infra" && git pull --ff-only

cd "$BASE/Flirt-infra"
docker compose -f docker-compose.prod.yml build api
docker compose -f docker-compose.prod.yml run --rm flyway migrate
docker compose -f docker-compose.prod.yml up -d api

# Health gate — fail the deploy if the API doesn't come back
for i in $(seq 1 30); do
  if curl -sf http://127.0.0.1:3001/health >/dev/null; then
    echo "Deploy OK — API healthy"
    exit 0
  fi
  sleep 2
done
echo "Deploy FAILED — API not healthy after 60s" >&2
docker compose -f docker-compose.prod.yml logs --tail 50 api >&2
exit 1
