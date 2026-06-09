#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
. scripts/plan-lib.sh

task="${1:-}"
step="${2:-}"

[[ "$task" =~ ^T-[0-9]{3}$ ]] || {
  echo "PLAN_GUARD_FAIL: missing or invalid task id" >&2
  exit 2
}

[[ "$step" =~ ^S-[0-9]{3}$ ]] || {
  echo "PLAN_GUARD_FAIL: missing or invalid step id" >&2
  exit 2
}

require_plan_guard="$(state_get require_plan_guard)"
if [[ "$require_plan_guard" != "true" ]]; then
  echo "PLAN_GUARD_SKIP: require_plan_guard is not true"
  exit 0
fi

plan_status="$(state_get plan_status)"
if [[ "$plan_status" != "locked" ]]; then
  echo "PLAN_GUARD_FAIL: plan not locked" >&2
  exit 1
fi

current_task="$(state_get current_task)"
if [[ "$current_task" != "$task" ]]; then
  echo "PLAN_GUARD_FAIL: task is not current" >&2
  exit 1
fi

current_step="$(state_get current_step)"
if [[ "$current_step" != "$step" ]]; then
  echo "PLAN_STEP_FAIL: step is not current" >&2
  exit 1
fi

plan="$(plan_file "$task")"
[[ -f "$plan" ]] || {
  echo "PLAN_GUARD_FAIL: missing plan" >&2
  exit 1
}

expected_hash="$(state_get plan_hash)"
actual_hash="$(plan_hash "$plan")"
if [[ -n "$expected_hash" && "$expected_hash" != "__PLAN_HASH__" && "$expected_hash" != "$actual_hash" ]]; then
  echo "PLAN_GUARD_FAIL: locked plan changed" >&2
  exit 1
fi

unauthorized=""
while IFS= read -r file; do
  [[ -n "$file" ]] || continue
  [[ "$file" == "docs/AI_STATE.yml" ]] && continue

  if file_forbidden_by_step "$plan" "$step" "$file"; then
    unauthorized+="$file"$'\n'
    continue
  fi

  if ! file_allowed_by_step "$plan" "$step" "$file"; then
    unauthorized+="$file"$'\n'
  fi
done < <(changed_files)

if [[ -n "$unauthorized" ]]; then
  echo "PLAN_GUARD_FAIL: unauthorized file" >&2
  printf '%s' "$unauthorized" >&2
  exit 1
fi

echo "PLAN_GUARD_PASS"
echo "current_task: $task"
echo "current_step: $step"
