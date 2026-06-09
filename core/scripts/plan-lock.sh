#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
. scripts/plan-lib.sh

task="${1:-}"
[[ "$task" =~ ^T-[0-9]{3}$ ]] || {
  echo "PLAN_LOCK_FAIL: missing or invalid task id" >&2
  exit 2
}

plan="$(plan_file "$task")"
[[ -f "$plan" ]] || {
  echo "PLAN_LOCK_FAIL: missing $plan" >&2
  exit 1
}

bash scripts/spec-lint.sh "$task" >/dev/null

requirements_status="$(state_get requirements_status)"
design_status="$(state_get design_status)"

if [[ "$task" != "T-000" && "$requirements_status" != "approved" ]]; then
  echo "PLAN_LOCK_FAIL: requirements not approved" >&2
  exit 1
fi

if [[ "$task" != "T-000" && "$design_status" != "approved" ]]; then
  echo "PLAN_LOCK_FAIL: design not approved" >&2
  exit 1
fi

step="$(first_step "$plan")"
[[ "$step" =~ ^S-[0-9]{3}$ ]] || {
  echo "PLAN_LOCK_FAIL: missing first step" >&2
  exit 1
}

state_set current_task "$task"
state_set plan_status locked
state_set workflow_status implementation
state_set current_step "$step"
state_set require_plan_guard true
state_set plan_change_status none
state_set plan_hash "$(plan_hash "$plan")"

echo "PLAN_LOCK_PASS"
echo "current_task: $task"
echo "current_step: $step"
