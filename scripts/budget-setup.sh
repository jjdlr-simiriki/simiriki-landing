#!/usr/bin/env bash
set -euo pipefail

SUB=${AZ_SUBSCRIPTION_ID:-}

if [[ -z "$SUB" ]]; then
  echo "Set AZ_SUBSCRIPTION_ID to create a budget." >&2
  exit 1
fi

echo "Creating MXN 10,000/month budget with 80% and 100% alerts..."
az account set -s "$SUB"
az consumption budget create \
  --amount 10000 \
  --category cost \
  --name budget-simiriki \
  --time-grain monthly \
  --time-period "start=$(date +%Y-%m-01),end=$(date -d "+1 year" +%Y-%m-01)" \
  --notifications '{"80":{"enabled":true,"operator":"GreaterThan","threshold":80},"100":{"enabled":true,"operator":"GreaterThan","threshold":100}}' \
  -o table
echo "Done."
