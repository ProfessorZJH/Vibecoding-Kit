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

[[ -f "$task_file" ]] || {
  echo "SPEC_LINT_FAIL: missing $task_file" >&2
  exit 1
}

[[ -f "$plan_file" ]] || {
  echo "SPEC_LINT_FAIL: missing $plan_file" >&2
  exit 1
}

if [[ "$task" != "T-000" ]]; then
  [[ -f "docs/specs/${task}-requirements.md" ]] || {
    echo "SPEC_LINT_FAIL: missing docs/specs/${task}-requirements.md" >&2
    exit 1
  }
  [[ -f "docs/designs/${task}-design.md" ]] || {
    echo "SPEC_LINT_FAIL: missing docs/designs/${task}-design.md" >&2
    exit 1
  }
fi

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
done < <(awk '/^## S-[0-9][0-9][0-9] / { print $2 }' "$plan_file")

echo "SPEC_LINT_PASS"
