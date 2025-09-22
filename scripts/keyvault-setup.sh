#!/usr/bin/env bash
set -euo pipefail

RG=${AZ_RG:-rg-simiriki-core}
KV_NAME=${AZ_KV_NAME:-simiriki-secrets}
LOC=${AZ_LOCATION:-Mexico Central}
SWA=${SWA_NAME:-simiriki-landing-new}
FUNC=${FUNCAPP_NAME:-func-simiriki-leadscore}

echo "Creating Key Vault $KV_NAME in $LOC..."
az keyvault create -g "$RG" -n "$KV_NAME" -l "$LOC" --enable-purge-protection true --enable-soft-delete true -o table || true

echo "Set secrets (edit values as needed) ..."
[[ -n "${STRIPE_SECRET_KEY:-}" ]] && az keyvault secret set --vault-name "$KV_NAME" -n STRIPE-SECRET-KEY --value "$STRIPE_SECRET_KEY" -o table || true
[[ -n "${STRIPE_PRICE_ID:-}"    ]] && az keyvault secret set --vault-name "$KV_NAME" -n STRIPE-PRICE-ID   --value "$STRIPE_PRICE_ID" -o table || true
[[ -n "${STRIPE_WEBHOOK_SECRET:-}" ]] && az keyvault secret set --vault-name "$KV_NAME" -n STRIPE-WEBHOOK-SECRET --value "$STRIPE_WEBHOOK_SECRET" -o table || true

echo "Grant access to Function App managed identity (if enabled) and set app settings to KV references."
echo "Note: Ensure the Function App has a system-assigned identity enabled."
echo "Example KV reference format: @Microsoft.KeyVault(SecretUri=https://$KV_NAME.vault.azure.net/secrets/STRIPE-SECRET-KEY)"

REF1="@Microsoft.KeyVault(SecretUri=https://$KV_NAME.vault.azure.net/secrets/STRIPE-SECRET-KEY)"
REF2="@Microsoft.KeyVault(SecretUri=https://$KV_NAME.vault.azure.net/secrets/STRIPE-PRICE-ID)"
REF3="@Microsoft.KeyVault(SecretUri=https://$KV_NAME.vault.azure.net/secrets/STRIPE-WEBHOOK-SECRET)"

az functionapp config appsettings set -g "$RG" -n "$FUNC" --settings \
  STRIPE_SECRET_KEY="$REF1" STRIPE_PRICE_ID="$REF2" STRIPE_WEBHOOK_SECRET="$REF3" || true

echo "For SWA, set app settings via az staticwebapp appsettings set using the same KV references."
az staticwebapp appsettings set -n "$SWA" -g "$RG" --setting-names \
  STRIPE_SECRET_KEY="$REF1" STRIPE_PRICE_ID="$REF2" STRIPE_WEBHOOK_SECRET="$REF3" || true

echo "Done. Review identities and access policies in Azure Portal if resolution fails."
