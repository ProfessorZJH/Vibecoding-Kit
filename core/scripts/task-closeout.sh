#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

task=""
no_tests=false
write_report=false
push=false
allow_main_push=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-tests) no_tests=true ;;
    --write-report) write_report=true ;;
    --push) push=true ;;
    --allow-main-push) allow_main_push=true ;;
    T-[0-9][0-9][0-9]) task="$1" ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done

[[ -n "$task" ]] || { echo "BLOCKED"; echo "reason: missing task"; exit 2; }
task_file="docs/tasks/${task}.md"
[[ -f "$task_file" ]] || { echo "BLOCKED"; echo "reason: missing task card $task_file"; exit 2; }

extract_allowed() {
  awk '
    $0 == "## Allowed Changes" { in_section = 1; next }
    in_section && /^## / { exit }
    in_section && /^- / { line=$0; sub(/^- /, "", line); gsub(/`/, "", line); print line }
  ' "$task_file"
}

is_allowed() {
  local file="$1"
  local pattern
  while IFS= read -r pattern; do
    [[ -n "$pattern" ]] || continue
    [[ "$pattern" == "**" ]] && return 0
    if [[ "$pattern" == *"/**" ]]; then
      local prefix="${pattern%/**}"
      [[ "$file" == "$prefix" || "$file" == "$prefix/"* ]] && return 0
    elif [[ "$pattern" == *"*"* ]]; then
      [[ "$file" == $pattern ]] && return 0
    else
      [[ "$file" == "$pattern" ]] && return 0
    fi
  done < <(extract_allowed)
  return 1
}

has_head=false
git rev-parse --verify HEAD >/dev/null 2>&1 && has_head=true

if [[ "$has_head" == true ]]; then
  tracked_changes="$(git diff --name-only HEAD)"
  deleted_files="$(git diff --name-only --diff-filter=D HEAD)"
  renamed_files="$(git diff --name-status --find-renames HEAD | awk '$1 ~ /^R/ { print $2 "\n" $3 }' | sort -u)"
else
  tracked_changes="$(git diff --name-only)"
  deleted_files=""
  renamed_files=""
fi

changed_files="$(
  {
    printf '%s\n' "$tracked_changes"
    git ls-files --others --exclude-standard
  } | sed '/^$/d' | sort -u
)"
staged_files="$(git diff --cached --name-only | sort -u)"

unauthorized=""
sensitive_files=""
local_artifacts=""
while IFS= read -r file; do
  [[ -n "$file" ]] || continue
  is_allowed "$file" || unauthorized+="$file"$'\n'
  case "$file" in
    .env|.env.*|*/.env|*/.env.*|*.pem|*.key|id_rsa|*/id_rsa|id_ed25519|*/id_ed25519)
      sensitive_files+="$file"$'\n'
      ;;
  esac
  case "$file" in
    target|target/*|*/target|*/target/*|.m2home|.m2home/*|*/.m2home|*/.m2home/*|.idea|.idea/*|*/.idea|*/.idea/*|node_modules|node_modules/*|*/node_modules|*/node_modules/*)
      local_artifacts+="$file"$'\n'
      ;;
  esac
done <<< "$changed_files"

tests_result="skipped_by_flag"
if [[ "$no_tests" == false ]]; then
  if [[ -z "${TASK_TEST_COMMAND:-}" ]]; then
    tests_result="NO_TEST_COMMAND"
  else
    bash -lc "$TASK_TEST_COMMAND"
    tests_result="TASK_TEST_COMMAND_PASS"
  fi
fi

bash scripts/drift-guard.sh >/dev/null
drift_result="DRIFT_GUARD_PASS"

plan_result="not_required"
require_plan_guard="$(awk -F: '$1 == "require_plan_guard" { v=$2; gsub(/^[ \t]+|[ \t]+$/, "", v); print v; exit }' docs/AI_STATE.yml 2>/dev/null || true)"
current_step="$(awk -F: '$1 == "current_step" { v=$2; gsub(/^[ \t]+|[ \t]+$/, "", v); print v; exit }' docs/AI_STATE.yml 2>/dev/null || true)"
if [[ "$require_plan_guard" == "true" ]]; then
  if [[ "$current_step" =~ ^S-[0-9]{3}$ ]]; then
    bash scripts/plan-guard.sh "$task" "$current_step" >/dev/null
    plan_result="PLAN_GUARD_PASS $current_step"
  else
    plan_result="PLAN_GUARD_FAIL missing_current_step"
  fi
fi

git_checkpoint="COMMIT_REQUIRED"
if [[ -z "$changed_files" && "$has_head" == true ]]; then
  latest_subject="$(git log -1 --pretty=%s)"
  latest_commit="$(git log -1 --pretty=%H)"
  if [[ "$latest_subject" == "$task:"* ]]; then
    git_checkpoint="COMMIT_CHECKPOINT $latest_commit"
  else
    git_checkpoint="NO_COMMIT_CHECKPOINT latest_commit_not_for_${task}"
  fi
fi

push_checkpoint="NO_PUSH_CHECKPOINT push_not_requested"
if [[ "$push" == true ]]; then
  branch="$(git rev-parse --abbrev-ref HEAD)"
  if [[ -n "$changed_files" ]]; then
    push_checkpoint="NO_PUSH_CHECKPOINT uncommitted_changes"
  elif [[ "$branch" =~ ^(main|master)$ && "$allow_main_push" == false ]]; then
    push_checkpoint="NO_PUSH_CHECKPOINT protected_branch_requires_approval"
  else
    git push -u origin "$branch"
    push_checkpoint="PUSH_CHECKPOINT origin $branch $(git rev-parse HEAD)"
  fi
fi

closeout_report="not_written"
if [[ "$write_report" == true ]]; then
  report_dir="${CLOSEOUT_REPORT_DIR:-reports/ai-closeout}"
  mkdir -p "$report_dir"
  closeout_report="$report_dir/${task}.md"
  cat >"$closeout_report" <<EOF
# AI Closeout - $task

## Files

### Changed

${changed_files:-none}

### Staged

${staged_files:-none}

### Deleted

${deleted_files:-none}

### Renamed

${renamed_files:-none}

### Unauthorized

${unauthorized:-none}

### Sensitive

${sensitive_files:-none}

### Local Artifacts

${local_artifacts:-none}

## Validation

- tests: $tests_result
- drift_guard: $drift_result
- plan_guard: $plan_result

## Checkpoints

- git: $git_checkpoint
- push: $push_checkpoint
EOF
fi

cat <<EOF
CLOSEOUT
current_task: $task
changed_files:
${changed_files:-  none}
staged_files:
${staged_files:-  none}
deleted_files:
${deleted_files:-  none}
renamed_files:
${renamed_files:-  none}
unauthorized_files:
${unauthorized:-  none}
sensitive_files:
${sensitive_files:-  none}
local_artifacts:
${local_artifacts:-  none}
tests_run: $tests_result
drift_guard: $drift_result
plan_guard: $plan_result
git_checkpoint: $git_checkpoint
push_checkpoint: $push_checkpoint
closeout_report: $closeout_report
EOF

[[ -z "$unauthorized" ]] || exit 1
[[ -z "$sensitive_files" ]] || exit 1
[[ -z "$local_artifacts" ]] || exit 1
[[ "$plan_result" != PLAN_GUARD_FAIL* ]] || exit 1
[[ "$tests_result" != "NO_TEST_COMMAND" ]] || exit 1
