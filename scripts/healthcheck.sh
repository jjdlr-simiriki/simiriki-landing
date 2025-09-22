#!/usr/bin/env bash
set -euo pipefail

URL=${1:-"https://www.simiriki.com"}
TEAMS=${TEAMS_WEBHOOK_URL:-}

http_code=$(curl -sS -o /dev/null -w "%{http_code}" -m 15 "$URL" || echo "000")
msg="SWA healthcheck: $URL -> $http_code"
echo "$msg"

if [[ -n "$TEAMS" && "$http_code" != 2* && "$http_code" != 3* ]]; then
  payload=$(jq -n --arg text "$msg" '{text:$text}')
  curl -sS -H 'Content-Type: application/json' -d "$payload" "$TEAMS" >/dev/null || true
fi
