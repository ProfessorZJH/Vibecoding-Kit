#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

block() {
  cat <<EOF >&2
BLOCKED
reason: $1
needs: ${2:-current task and task card}
suggested_next_step: ${3:-set docs/AI_STATE.yml current_task or pass T-xxx explicitly}
EOF
  exit 2
}

task_from_ai_state() {
  local file="${AI_STATE_FILE:-docs/AI_STATE.yml}"
  [[ -f "$file" ]] || return 0
  awk -F: '$1 == "current_task" { v=$2; gsub(/^[ \t]+|[ \t]+$/, "", v); if (v ~ /^T-[0-9][0-9][0-9]$/) print v; exit }' "$file"
}

task_from_project_state() {
  rg -o "current_task:[[:space:]]*T-[0-9]{3}" docs/PROJECT_STATE.md 2>/dev/null \
    | head -n 1 \
    | sed -E 's/.*(T-[0-9]{3}).*/\1/'
}

print_section() {
  local title="$1"
  local file="$2"
  awk -v wanted="$title" '
    $0 == wanted { in_section = 1; next }
    in_section && /^## / { exit }
    in_section && NF { print "  " $0 }
  ' "$file"
}

task="${1:-}"
state_source="argument"
if [[ -z "$task" ]]; then
  state_source="${AI_STATE_FILE:-docs/AI_STATE.yml}"
  task="$(task_from_ai_state || true)"
fi
if [[ -z "$task" ]]; then
  state_source="docs/PROJECT_STATE.md"
  task="$(task_from_project_state || true)"
fi

[[ "$task" =~ ^T-[0-9]{3}$ ]] || block "invalid or missing task: ${task:-none}"

task_file="docs/tasks/${task}.md"
[[ -f "$task_file" ]] || block "missing task card: $task_file" "$task_file" "create a task card first"

for section in "## Allowed Changes" "## Forbidden Changes" "## Test Requirements" "## Completion Criteria"; do
  rg -q "^${section}$" "$task_file" || block "task card missing section: $section" "$task_file" "fill the task card template"
done

git_status="clean"
[[ -z "$(git status --short 2>/dev/null || true)" ]] || git_status="dirty"

cat <<EOF
PRECHECK
current_task: $task
task_card: $task_file
state_source: $state_source
git_status: $git_status
allowed_files:
$(print_section "## Allowed Changes" "$task_file")
forbidden_files:
$(print_section "## Forbidden Changes" "$task_file")
validation_commands:
$(print_section "## Test Requirements" "$task_file")
blocked_if:
  - current task is unclear
  - task card is incomplete
  - required changes are outside allowed scope
  - guard scripts fail
EOF
