#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

finance_hits="$(rg -n '\bdouble\b|\bfloat\b' --glob '*.java' --glob '!**/target/**' . 2>/dev/null || true)"
if [[ -n "$finance_hits" ]]; then
  echo "FINANCE_DRIFT"
  echo "location: amount type scan"
  echo "reason: finance code must not use double/float for amounts"
  echo "$finance_hits"
  exit 1
fi

echo "FINANCE_GUARD_PASS"
