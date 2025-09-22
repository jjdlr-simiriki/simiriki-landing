#!/usr/bin/env bash
set -euo pipefail

DEST_DIR=${1:-"./backups/reports"}
CONN_STR=${AZURE_STORAGE_CONNECTION_STRING:-}
ACCOUNT_NAME=${AZURE_STORAGE_ACCOUNT:-stsimirikinegocio}

if [[ -z "$CONN_STR" ]]; then
  echo "AZURE_STORAGE_CONNECTION_STRING is required." >&2
  exit 1
fi

mkdir -p "$DEST_DIR"
az storage blob download-batch \
  --connection-string "$CONN_STR" \
  --source reports \
  --destination "$DEST_DIR" \
  --no-progress
echo "Reports synced to $DEST_DIR"

