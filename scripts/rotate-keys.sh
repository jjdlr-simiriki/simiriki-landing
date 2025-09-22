#!/usr/bin/env bash
set -euo pipefail

RG=${AZ_RG:-rg-simiriki-core}
SA=${AZ_STORAGE_ACCOUNT:-stsimirikinegocio}
SWA=${SWA_NAME:-simiriki-landing-new}
FUNC=${FUNCAPP_NAME:-func-simiriki-leadscore}
DRY_RUN=${DRY_RUN:-true}

echo "Resource Group: $RG"
echo "Storage Account: $SA"
echo "SWA: $SWA"
echo "Function App: $FUNC"
echo "DRY_RUN=$DRY_RUN"

echo "Fetching storage keys..."
mapfile -t KEYS < <(az storage account keys list -g "$RG" -n "$SA" --query "[].{keyName:keyName,value:value}" -o tsv)
KEY1="${KEYS[0]##*$'\t'}"
KEY2="${KEYS[1]##*$'\t'}"

CONN1="DefaultEndpointsProtocol=https;AccountName=$SA;AccountKey=$KEY1;EndpointSuffix=core.windows.net"
CONN2="DefaultEndpointsProtocol=https;AccountName=$SA;AccountKey=$KEY2;EndpointSuffix=core.windows.net"

echo "Updating app settings to use KEY2 (without regen) to avoid downtime..."
if [[ "$DRY_RUN" != "true" ]]; then
  az staticwebapp appsettings set -n "$SWA" -g "$RG" --setting-names AZURE_STORAGE_CONNECTION_STRING="$CONN2" || true
  az functionapp config appsettings set -g "$RG" -n "$FUNC" --settings AZURE_STORAGE_CONNECTION_STRING="$CONN2" || true
else
  echo "(dry-run) Would set AZURE_STORAGE_CONNECTION_STRING to KEY2 for SWA and Function."
fi

echo "Regenerating KEY1..."
if [[ "$DRY_RUN" != "true" ]]; then
  az storage account keys renew -g "$RG" -n "$SA" --key primary
else
  echo "(dry-run) Would renew primary key."
fi

echo "Switching apps to KEY1 (new) and regenerating KEY2..."
if [[ "$DRY_RUN" != "true" ]]; then
  NEW1=$(az storage account keys list -g "$RG" -n "$SA" --query "[0].value" -o tsv)
  NEW_CONN1="DefaultEndpointsProtocol=https;AccountName=$SA;AccountKey=$NEW1;EndpointSuffix=core.windows.net"
  az staticwebapp appsettings set -n "$SWA" -g "$RG" --setting-names AZURE_STORAGE_CONNECTION_STRING="$NEW_CONN1" || true
  az functionapp config appsettings set -g "$RG" -n "$FUNC" --settings AZURE_STORAGE_CONNECTION_STRING="$NEW_CONN1" || true
  az storage account keys renew -g "$RG" -n "$SA" --key secondary
else
  echo "(dry-run) Would switch apps to new KEY1 and then renew secondary."
fi

echo "Done."

