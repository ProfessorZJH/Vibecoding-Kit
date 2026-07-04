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
  echo "PLAN_STEP_FAIL: task is not current (requested: $task, current: ${current_task:-none})" >&2
  exit 1
}

[[ "$current_step" == "$step" ]] || {
  echo "PLAN_STEP_FAIL: step is not current (requested: $step, current: ${current_step:-none})" >&2
  exit 1
}

[[ "$plan_status" == "locked" ]] || {
  echo "PLAN_STEP_FAIL: plan not locked" >&2
  exit 1
}

step_requires_commit() {
  local rule

  [[ "$(state_get require_step_commit)" == "true" ]] && return 0

  while IFS= read -r rule; do
    [[ "$rule" == "required" ]] && return 0
  done < <(step_field "$plan" "$step" "commit")

  return 1
}

enforce_commit_checkpoint() {
  local changes
  local latest_subject

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "PLAN_STEP_FAIL: commit required (not_git_repository)" >&2
    exit 1
  fi

  if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
    echo "PLAN_STEP_FAIL: commit required (missing_commit_checkpoint)" >&2
    exit 1
  fi

  changes="$(changed_files)"
  if [[ -n "$changes" ]]; then
    echo "PLAN_STEP_FAIL: commit required (uncommitted_changes)" >&2
    printf '%s\n' "$changes" >&2
    exit 1
  fi

  latest_subject="$(git log -1 --pretty=%s)"
  if [[ "$latest_subject" != "$task:"* ]]; then
    echo "PLAN_STEP_FAIL: commit required (latest_commit_not_for_${task})" >&2
    exit 1
  fi
}

case "$action" in
  --start)
    state_set workflow_status implementation
    echo "PLAN_STEP_START"
    echo "current_task: $task"
    echo "current_step: $step"
    ;;
  --complete)
    bash scripts/plan-guard.sh "$task" "$step" >/dev/null
    if step_requires_commit; then
      enforce_commit_checkpoint
    fi
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
