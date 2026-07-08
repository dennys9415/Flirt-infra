#!/usr/bin/env bash
# Pull-based CD — runs ON the server every 2 minutes (systemd timer).
# Deploys when origin/main of Flirt-api moves AND its CI checks are green.
# Rationale: SSH port stays closed to the world (no push-from-GitHub);
# the server reaches out to GitHub instead. See flirt-docs/HANDOFF.md.
set -euo pipefail

BASE="${FLIRT_BASE:-/opt/flirt}"
REPO="dennys9415/Flirt-api"

# Never overlap two deploys
exec 9>/var/run/flirt-deploy.lock
flock -n 9 || exit 0

cd "$BASE/Flirt-api"
git fetch -q origin main
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)
[ "$LOCAL" = "$REMOTE" ] && exit 0

# Require green CI on the candidate commit (public API, no token needed)
CI_STATE=$(curl -fsS --max-time 20 \
  -H 'Accept: application/vnd.github+json' \
  "https://api.github.com/repos/$REPO/commits/$REMOTE/check-runs" \
  | python3 -c '
import json, sys
runs = json.load(sys.stdin).get("check_runs", [])
if not runs:
    print("pending")
elif any(r.get("conclusion") in ("failure", "cancelled", "timed_out") for r in runs):
    print("failure")
elif all(r.get("status") == "completed" and r.get("conclusion") == "success" for r in runs):
    print("success")
else:
    print("pending")' 2>/dev/null || echo "unknown")

if [ "$CI_STATE" != "success" ]; then
  echo "$(date -Is) candidate ${REMOTE:0:7} CI=$CI_STATE — not deploying"
  exit 0
fi

echo "$(date -Is) deploying ${REMOTE:0:7} (CI green)"
bash "$BASE/Flirt-infra/scripts/deploy.sh"
