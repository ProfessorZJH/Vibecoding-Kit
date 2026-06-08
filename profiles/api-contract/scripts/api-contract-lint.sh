#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

task="${1:-}"
if [[ -n "$task" && ! "$task" =~ ^T-[0-9]{3}$ ]]; then
  echo "API_CONTRACT_LINT_FAIL: invalid task id" >&2
  exit 2
fi

[[ -f docs/API_SPEC.md ]] || {
  echo "API_CONTRACT_LINT_FAIL: docs/API_SPEC.md missing" >&2
  exit 1
}

for field in method path permission request response error_codes business_rules audit; do
  if ! rg -q "${field}:" docs/API_SPEC.md; then
    echo "API_CONTRACT_LINT_FAIL: docs/API_SPEC.md missing ${field}" >&2
    exit 1
  fi
done

if [[ -n "$task" && -f "docs/tasks/${task}.md" ]]; then
  task_file="docs/tasks/${task}.md"
  if rg -qi 'api|controller|route|endpoint|接口' "$task_file"; then
    if ! rg -q 'API|method|path|permission|错误码|error' "$task_file"; then
      echo "API_CONTRACT_LINT_FAIL: API-related task lacks API contract details" >&2
      exit 1
    fi
  fi
fi

echo "API_CONTRACT_LINT_PASS"
