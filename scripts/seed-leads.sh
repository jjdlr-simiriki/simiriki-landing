#!/usr/bin/env bash
set -euo pipefail

URL=${LEAD_FUNC_URL:-}
CODE_QS=${LEAD_FUNC_CODE:+"?code=$LEAD_FUNC_CODE"}
COUNT=${1:-10}

if [[ -z "$URL" ]]; then
  echo "Set LEAD_FUNC_URL (e.g., https://func-simiriki-leadscore.azurewebsites.net/api/lead)" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required. Install jq and re-run." >&2
  exit 2
fi

names=("Ana" "Luis" "Carlos" "Sara" "Diana" "Pablo" "Lucía" "Jorge" "María" "Diego")
domains=("example.com" "acme.mx" "contoso.com" "empresa.mx")

for i in $(seq 1 "$COUNT"); do
  name=${names[$RANDOM % ${#names[@]}]}
  domain=${domains[$RANDOM % ${#domains[@]}]}
  email="${name,,}.$RANDOM@$domain"
  phone="+52 81$((RANDOM%90000000+10000000))"
  company="SMB-$((RANDOM%900+100))"
  payload=$(jq -n --arg name "$name" --arg email "$email" --arg phone "$phone" --arg company "$company" '{name:$name,email:$email,phone:$phone,company:$company}')
  echo "POST $URL$CODE_QS -> $email"
  curl -sS -m 10 -H 'Content-Type: application/json' -d "$payload" "$URL$CODE_QS" | jq -r '.status // .error' || true
  sleep 0.3
done

