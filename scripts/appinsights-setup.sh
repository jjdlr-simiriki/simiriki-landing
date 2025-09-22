#!/usr/bin/env bash
set -euo pipefail

RG=${AZ_RG:-rg-simiriki-core}
LOC=${AZ_LOCATION:-Mexico Central}
AI_NAME=${AI_NAME:-appi-simiriki}
FUNC=${FUNCAPP_NAME:-func-simiriki-leadscore}

echo "Creating Application Insights ($AI_NAME) in $LOC ..."
az monitor app-insights component create -g "$RG" -l "$LOC" -a "$AI_NAME" -o table || true

CONN=$(az monitor app-insights component show -g "$RG" -a "$AI_NAME" --query connectionString -o tsv)
echo "Connecting Function App to App Insights ..."
az functionapp config appsettings set -g "$RG" -n "$FUNC" --settings APPLICATIONINSIGHTS_CONNECTION_STRING="$CONN" -o table

echo "Set retention to 90 days"
az monitor app-insights component update -g "$RG" -a "$AI_NAME" --retention-time 90 -o table

echo "Done."
