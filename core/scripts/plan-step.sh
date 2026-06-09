#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
. scripts/plan-lib.sh

task="${1:-}"
step="${2:-}"
action="${3:-}"

[[ "$task" =~ ^T-[0-9]{3}$ ]] || {
  echo "PLAN_STEP_FAIL: missing or invalid task id" >&2
  exit 2
}

[[ "$step" =~ ^S-[0-9]{3}$ ]] || {
  echo "PLAN_STEP_FAIL: missing or invalid step id" >&2
  exit 2
}

case "$action" in
  --start|--complete|--block) ;;
  *)
    echo "PLAN_STEP_FAIL: invalid action" >&2
    exit 2
    ;;
esac

plan="$(plan_file "$task")"
[[ -f "$plan" ]] || {
  echo "PLAN_STEP_FAIL: missing plan" >&2
  exit 1
}

current_task="$(state_get current_task)"
current_step="$(state_get current_step)"
plan_status="$(state_get plan_status)"

[[ "$current_task" == "$task" ]] || {
  echo "PLAN_STEP_FAIL: task is not current" >&2
  exit 1
}

[[ "$current_step" == "$step" ]] || {
  echo "PLAN_STEP_FAIL: step is not current" >&2
  exit 1
}

[[ "$plan_status" == "locked" ]] || {
  echo "PLAN_STEP_FAIL: plan not locked" >&2
  exit 1
}

case "$action" in
  --start)
    state_set workflow_status implementation
    echo "PLAN_STEP_START"
    echo "current_task: $task"
    echo "current_step: $step"
    ;;
  --complete)
    bash scripts/plan-guard.sh "$task" "$step" >/tmp/vibecoding-kit-plan-guard.out
    next="$(next_step_after "$plan" "$step")"
    if [[ -n "$next" ]]; then
      state_set current_step "$next"
      state_set workflow_status implementation
    else
      state_set workflow_status closeout
    fi
    echo "PLAN_STEP_COMPLETE"
    echo "completed_step: $step"
    echo "next_step: ${next:-none}"
    ;;
  --block)
    state_set workflow_status blocked
    state_set plan_change_status requested
    echo "PLAN_STEP_BLOCKED"
    echo "current_task: $task"
    echo "current_step: $step"
    ;;
esac
