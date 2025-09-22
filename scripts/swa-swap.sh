#!/usr/bin/env bash
set -euo pipefail

# Roll back to a previous GitHub Actions deploy by rerunning a prior workflow run
# Requires GitHub CLI (gh) authenticated with repo scope.

WF=${WORKFLOW_FILE:-.github/workflows/deploy-swa.yml}
RUN_INDEX=${1:-2} # 1 = latest, 2 = previous successful

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) is required. Install and run 'gh auth login'." >&2
  exit 1
fi

echo "Fetching recent workflow runs for $WF ..."
mapfile -t RUNS < <(gh run list --workflow "$WF" --json databaseId,status,conclusion -q '.[] | select(.conclusion=="success") | .databaseId')

if [[ ${#RUNS[@]} -lt $RUN_INDEX ]]; then
  echo "Not enough successful runs to roll back to index $RUN_INDEX." >&2
  exit 2
fi

TARGET_ID=${RUNS[$((RUN_INDEX-1))]}
echo "Re-running workflow run ID $TARGET_ID ..."
gh run rerun "$TARGET_ID" --failed
echo "Triggered rerun. Monitor progress in GitHub Actions."

