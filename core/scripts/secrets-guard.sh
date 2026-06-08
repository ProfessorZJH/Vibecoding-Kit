#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

files="$(
  {
    git ls-files 2>/dev/null
    git ls-files --others --exclude-standard 2>/dev/null
  } | sort -u
)"

patterns='-----BEGIN (RSA |OPENSSH |EC |DSA )?PRIVATE KEY-----|AKIA[0-9A-Z]{16}|sk-[A-Za-z0-9_-]{20,}|(?i)(api[_-]?key|secret|token|password)[[:space:]]*[:=][[:space:]]*['\''"]?[A-Za-z0-9_./+=:-]{12,}|jdbc:mysql://[^[:space:]]+:[^[:space:]@]+@'

hits=""
while IFS= read -r file; do
  [[ -n "$file" ]] || continue
  [[ -f "$file" ]] || continue
  case "$file" in
    .git/*|scripts/secrets-guard.sh|profiles/ddd/xfg-archetype/*|docs/reference/xfg-ddd-scaffold-lite-jdk17/*)
      continue
      ;;
    *.jar|*.png|*.jpg|*.jpeg|*.gif|*.ico|*.pdf|*.zip|*.gz)
      continue
      ;;
  esac
  file_hits="$(rg -n -- "$patterns" "$file" 2>/dev/null || true)"
  if [[ -n "$file_hits" ]]; then
    hits+="$file_hits"$'\n'
  fi
done <<< "$files"

if [[ -n "$hits" ]]; then
  echo "SECRETS_GUARD_FAIL"
  echo "$hits"
  exit 1
fi

echo "SECRETS_GUARD_PASS"
