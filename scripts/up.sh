#!/usr/bin/env bash
# Start the full local stack (postgres → flyway migrate → redis → api → adminer).
set -euo pipefail
cd "$(dirname "$0")/.."

# Bootstrap env files from examples on first run
for f in env/*.env.example; do
  target="${f%.example}"
  if [ ! -f "$target" ]; then
    cp "$f" "$target"
    echo "Created $target from example"
  fi
done

docker compose up -d --build
docker compose ps
