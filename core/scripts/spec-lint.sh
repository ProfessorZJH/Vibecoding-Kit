#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

task="${1:-}"
[[ "$task" =~ ^T-[0-9]{3}$ ]] || {
  echo "SPEC_LINT_FAIL: missing or invalid task id" >&2
  exit 2
}

task_file="docs/tasks/${task}.md"
plan_file="docs/plans/${task}-plan.md"

status_value() {
  local file="$1"
  awk -F: '
    $1 == "status" {
      v = substr($0, index($0, ":") + 1)
      gsub(/^[ \t]+|[ \t]+$/, "", v)
      print v
      exit
    }
  ' "$file"
}

validate_status() {
  local label="$1"
  local value="$2"
  shift 2
  local allowed

  for allowed in "$@"; do
    [[ "$value" == "$allowed" ]] && return 0
  done

  echo "SPEC_LINT_FAIL: unsupported $label status ${value:-missing}" >&2
  exit 1
}

[[ -f "$task_file" ]] || {
  echo "SPEC_LINT_FAIL: missing $task_file" >&2
  exit 1
}

[[ -f "$plan_file" ]] || {
  echo "SPEC_LINT_FAIL: missing $plan_file" >&2
  exit 1
}

if [[ "$task" != "T-000" ]]; then
  requirements_file="docs/specs/${task}-requirements.md"
  design_file="docs/designs/${task}-design.md"

  [[ -f "$requirements_file" ]] || {
    echo "SPEC_LINT_FAIL: missing $requirements_file" >&2
    exit 1
  }
  [[ -f "$design_file" ]] || {
    echo "SPEC_LINT_FAIL: missing $design_file" >&2
    exit 1
  }

  validate_status "requirements" "$(status_value "$requirements_file")" draft approved change_required
  validate_status "design" "$(status_value "$design_file")" draft approved change_required
fi

validate_status "plan" "$(status_value "$plan_file")" draft locked change_required

for section in "## Goal" "## Background" "## Plan Contract" "## Allowed Changes" "## Forbidden Changes" "## Required Work" "## Forbidden Actions" "## Test Requirements" "## Completion Criteria" "## Risk"; do
  if ! rg -q "^${section}$" "$task_file"; then
    echo "SPEC_LINT_FAIL: $task_file missing $section" >&2
    exit 1
  fi
done

if ! rg -q '^## S-[0-9]{3} ' "$plan_file"; then
  echo "SPEC_LINT_FAIL: $plan_file missing plan steps" >&2
  exit 1
fi

duplicate_step="$(awk '/^## S-[0-9][0-9][0-9] / { if (++seen[$2] == 2) { print $2; exit } }' "$plan_file")"
if [[ -n "$duplicate_step" ]]; then
  echo "SPEC_LINT_FAIL: $plan_file duplicate step $duplicate_step" >&2
  exit 1
fi

while IFS= read -r step; do
  block="$(awk -v step="$step" '
    $0 ~ "^## " step " " { in_step = 1; print; next }
    in_step && /^## S-[0-9][0-9][0-9] / { exit }
    in_step { print }
  ' "$plan_file")"

  for field in status allowed_changes forbidden_changes commands expected commit; do
    if ! printf '%s\n' "$block" | rg -q "^${field}:"; then
      echo "SPEC_LINT_FAIL: $plan_file $step missing $field" >&2
      exit 1
    fi
  done

  step_status="$(printf '%s\n' "$block" | awk -F: '
    $1 == "status" {
      v = substr($0, index($0, ":") + 1)
      gsub(/^[ \t]+|[ \t]+$/, "", v)
      print v
      exit
    }
  ')"
  validate_status "step" "$step_status" pending in_progress completed blocked
done < <(awk '/^## S-[0-9][0-9][0-9] / { print $2 }' "$plan_file")

echo "SPEC_LINT_PASS"
