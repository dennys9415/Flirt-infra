#!/usr/bin/env bash
# Run pending Flyway migrations against the running postgres.
set -euo pipefail
cd "$(dirname "$0")/.."
docker compose run --rm flyway migrate
