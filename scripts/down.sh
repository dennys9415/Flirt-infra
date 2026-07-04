#!/usr/bin/env bash
# Stop the stack. Pass -v to also delete volumes (fresh database).
set -euo pipefail
cd "$(dirname "$0")/.."
docker compose down "$@"
