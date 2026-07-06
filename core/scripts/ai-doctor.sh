#!/usr/bin/env bash
set -euo pipefail

failures=0

check_file() {
  local path="$1"

  if [[ -f "$path" ]]; then
    echo "$path: ok"
  else
    echo "$path: missing"
    failures=$((failures + 1))
  fi
}

check_executable() {
  local path="$1"

  if [[ -x "$path" ]]; then
    echo "$path: executable"
  elif [[ -f "$path" ]]; then
    echo "$path: not executable"
    failures=$((failures + 1))
  else
    echo "$path: missing"
    failures=$((failures + 1))
  fi
}

echo "DOCTOR"

check_file "docs/AI_STATE.yml"
check_file "docs/tasks/T-000.md"
check_file "docs/plans/T-000-plan.md"

check_executable "scripts/ai-preflight.sh"
check_executable "scripts/drift-guard.sh"
check_executable "scripts/task-closeout.sh"
check_executable "scripts/risk-report.sh"
check_executable "scripts/secrets-guard.sh"

if [[ "$failures" -gt 0 ]]; then
  echo "DOCTOR_FAIL"
  exit 1
fi

echo "DOCTOR_PASS"
