#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

failures=0

record_failure() {
  failures=$((failures + 1))
  {
    echo "ARCHITECTURE_DRIFT"
    echo "location: $1"
    echo "reason: $2"
    echo "verify: bash scripts/architecture-guard.sh"
  } >&2
}

scan_imports() {
  local name="$1"
  local path_glob="$2"
  local pattern="$3"
  local paths
  paths="$(find . -path "$path_glob" -type d | sed 's#^\./##' || true)"
  [[ -n "$paths" ]] || return 0
  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    hits="$(rg -n "^import ${pattern}" "$path" --glob '*.java' 2>/dev/null || true)"
    [[ -z "$hits" ]] || record_failure "$name" "$hits"
  done <<< "$paths"
}

scan_imports "domain must not import infrastructure/trigger" "*-domain/src/main/java" '.*\.(infrastructure|trigger)\.'
scan_imports "api must not import implementation layers" "*-api/src/main/java" '.*\.(domain|infrastructure|trigger|usecase)\.'
scan_imports "types must not import implementation layers" "*-types/src/main/java" '.*\.(api|domain|infrastructure|trigger|usecase)\.'
scan_imports "trigger must not import DAO/PO" "*-trigger/src/main/java" '.*\.infrastructure\.dao(\.|;)'

controller_hits="$(find . -path '*-trigger/src/main/java' -type d -print0 | xargs -0 -r rg -n '^import .*Mapper|^import .*Dao' --glob '*Controller.java' 2>/dev/null || true)"
[[ -z "$controller_hits" ]] || record_failure "controllers must not import DAO/Mapper" "$controller_hits"

mybatis_hits="$(find . -path '*-domain/src/main/java' -type d -print0 | xargs -0 -r rg -n '^import (com\.baomidou\.mybatisplus|org\.apache\.ibatis)\.' --glob '*.java' 2>/dev/null || true)"
[[ -z "$mybatis_hits" ]] || record_failure "domain must not import MyBatis" "$mybatis_hits"

if [[ "$failures" -gt 0 ]]; then
  exit 1
fi

echo "ARCHITECTURE_GUARD_PASS"
