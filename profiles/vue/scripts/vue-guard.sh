#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

node_hits="$(git ls-files --others --cached --exclude-standard 2>/dev/null | rg '(^|/)node_modules(/|$)' || true)"
if [[ -n "$node_hits" ]]; then
  echo "VUE_DRIFT"
  echo "reason: node_modules/ must not be committed"
  echo "$node_hits"
  exit 1
fi

echo "VUE_GUARD_PASS"
