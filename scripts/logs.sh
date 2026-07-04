#!/usr/bin/env bash
# Tail logs. Usage: ./scripts/logs.sh [service]
set -euo pipefail
cd "$(dirname "$0")/.."
docker compose logs -f "${1:-}"
