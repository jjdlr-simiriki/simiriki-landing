#!/usr/bin/env bash
set -euo pipefail

# Note: Static Web Apps do not expose a direct CLI log tail. This helper provides two options:
# 1) Local dev: tail the local CSP/static server logs (.csp-server.log)
# 2) If Diagnostic Settings stream to Log Analytics are enabled, query last 200 logs

MODE=${1:-local}

if [[ "$MODE" == "local" ]]; then
  FILE=${2:-".csp-server.log"}
  if [[ ! -f "$FILE" ]]; then
    echo "No local log file ($FILE). Start with: node csp-server.js > .csp-server.log 2>&1 &" >&2
    exit 1
  fi
  tail -n 200 -f "$FILE"
  exit 0
fi

if [[ "$MODE" == "la" ]]; then
  if [[ -z "${LOG_WORKSPACE_ID:-}" ]]; then
    echo "Set LOG_WORKSPACE_ID and LOG_SHARED_KEY to query Log Analytics." >&2
    exit 2
  fi
  # Example Kusto query; adjust table/name to environment
  QUERY="AzureDiagnostics | where ResourceProvider == 'MICROSOFT.WEB/STATICSITES' | top 200 by TimeGenerated desc"
  az monitor log-analytics query --workspace "$LOG_WORKSPACE_ID" --analytics-query "$QUERY" -o table
  exit 0
fi

echo "Usage: $0 [local|la] [logfile]" >&2
exit 1

