#!/usr/bin/env bash
set -euo pipefail

RG=${AZ_RG:-rg-simiriki-core}
FUNC=${FUNCAPP_NAME:-func-simiriki-leadscore}
AI_RES_ID=${AI_RES_ID:-}
ACTION_GROUP=${ACTION_GROUP_NAME:-ag-simiriki-ops}
EMAIL=${ALERT_EMAIL:-ops@simiriki.com}

if [[ -z "$AI_RES_ID" ]]; then
  echo "Set AI_RES_ID to the Application Insights resource ID." >&2
  exit 1
fi

echo "Create action group ($ACTION_GROUP) ..."
az monitor action-group create -g "$RG" -n "$ACTION_GROUP" \
  --short-name simiops --action email Ops "$EMAIL" -o table || true

AG_ID=$(az monitor action-group show -g "$RG" -n "$ACTION_GROUP" --query id -o tsv)

echo "Create metric alert: Function errors >5 in 5 minutes"
az monitor metrics alert create -g "$RG" -n func-errors-high \
  --scopes "$AI_RES_ID" \
  --condition "count customMetrics | where name=='exceptions/count' > 5" \
  --window-size 5m --severity 2 --action "$AG_ID"

echo "Done."
