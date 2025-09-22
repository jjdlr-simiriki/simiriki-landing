#!/usr/bin/env bash
set -euo pipefail

RG=${AZ_RG:-rg-simiriki-core}
ASP=${AZ_APP_SERVICE_PLAN:-asp-simiriki-negocio}

echo "Applying autoscale rules on $ASP ..."
az monitor autoscale create -g "$RG" -n asp-autoscale --resource "$ASP" --resource-type Microsoft.Web/serverfarms --min-count 1 --max-count 5 --count 1 -o table || true

az monitor autoscale rule create -g "$RG" --autoscale-name asp-autoscale \
  --condition "Percentage CPU > 70 avg 10m" --scale out 1 || true

az monitor autoscale rule create -g "$RG" --autoscale-name asp-autoscale \
  --condition "Percentage CPU < 30 avg 10m" --scale in 1 || true

echo "Done."
