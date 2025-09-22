#!/usr/bin/env bash
set -euo pipefail

LOC=${AZ_LOCATION:-mexicocentral}

echo "Listing common VM SKUs in $LOC (partial)"
az vm list-skus -l "$LOC" --size Standard_D --all -o table | head -n 50

cat <<EON

To evaluate reserved instances vs pay-as-you-go:
- Retrieve current rates via Azure Retail Prices API:
  https://prices.azure.com/api/retail/prices?currencyCode=MXN&$filter=armRegionName eq '$LOC' and serviceName eq 'Virtual Machines'
- Compare 1-year/3-year reserved vs PAYG for your target SKU.
- Calculate break-even: RI upfront / (PAYG hourly - RI hourly).
EON
