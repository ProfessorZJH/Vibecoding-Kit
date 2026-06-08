#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

current_task="$(awk -F: '$1 == "current_task" { v=$2; gsub(/^[ \t]+|[ \t]+$/, "", v); print v; exit }' docs/AI_STATE.yml 2>/dev/null || true)"
if [[ "$current_task" =~ ^T-[0-9]{3}$ ]]; then
  bash scripts/api-contract-lint.sh "$current_task"
else
  bash scripts/api-contract-lint.sh
fi
