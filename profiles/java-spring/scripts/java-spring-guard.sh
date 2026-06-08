#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

target_hits="$(git ls-files --others --cached --exclude-standard 2>/dev/null | rg '(^|/)target(/|$)' || true)"
if [[ -n "$target_hits" ]]; then
  echo "JAVA_SPRING_DRIFT"
  echo "reason: target/ must not be committed"
  echo "$target_hits"
  exit 1
fi

echo "JAVA_SPRING_GUARD_PASS"
