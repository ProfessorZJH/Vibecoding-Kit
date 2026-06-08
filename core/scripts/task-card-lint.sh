#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

task="${1:-}"
[[ "$task" =~ ^T-[0-9]{3}$ ]] || {
  echo "TASK_CARD_LINT_FAIL: missing or invalid task id" >&2
  exit 2
}

task_file="docs/tasks/${task}.md"
[[ -f "$task_file" ]] || {
  echo "TASK_CARD_LINT_FAIL: missing $task_file" >&2
  exit 1
}

required_sections=(
  "## Goal"
  "## Background"
  "## Allowed Changes"
  "## Forbidden Changes"
  "## Required Work"
  "## Forbidden Actions"
  "## Test Requirements"
  "## Completion Criteria"
  "## Risk"
)

for section in "${required_sections[@]}"; do
  if ! rg -q "^${section}$" "$task_file"; then
    echo "TASK_CARD_LINT_FAIL: $task_file missing $section" >&2
    exit 1
  fi
done

risk="$(awk '$0 == "## Risk" { in_section=1; next } in_section && /^## / { exit } in_section && NF { print tolower($0); exit }' "$task_file")"
if [[ "$risk" == *"high"* || "$risk" == *"高"* ]]; then
  if ! rg -q '^## Review Requirements$|strong model review|强模型' "$task_file"; then
    echo "TASK_CARD_LINT_FAIL: high-risk task requires review requirements" >&2
    exit 1
  fi
fi

echo "TASK_CARD_LINT_PASS"
