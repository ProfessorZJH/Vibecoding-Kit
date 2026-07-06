#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

TARGET="$TMP_DIR/generated-project-demo"

say() {
  printf '%s\n' "$*"
}

assert_file() {
  [[ -f "$1" ]] || {
    printf 'DEMO_FAIL: missing file: %s\n' "$1" >&2
    exit 1
  }
}

assert_executable() {
  [[ -x "$1" ]] || {
    printf 'DEMO_FAIL: missing executable: %s\n' "$1" >&2
    exit 1
  }
}

assert_contains() {
  local text="$1"
  local expected="$2"

  [[ "$text" == *"$expected"* ]] || {
    printf 'DEMO_FAIL: expected output to contain: %s\n' "$expected" >&2
    exit 1
  }
}

print_matching_lines() {
  local text="$1"
  local pattern="$2"

  printf '%s\n' "$text" | rg "$pattern"
}

GIT_CONFIG_COUNT=1 \
GIT_CONFIG_KEY_0=init.defaultBranch \
GIT_CONFIG_VALUE_0=master \
bash "$ROOT_DIR/installer/init.sh" \
  --target "$TARGET" \
  --name generated-project-demo \
  --profile agent-adapters \
  --ci none >/dev/null

say "DEMO_STEP generated_project_installed"

assert_file "$TARGET/docs/AI_STATE.yml"
assert_file "$TARGET/docs/tasks/T-000.md"
assert_file "$TARGET/docs/plans/T-000-plan.md"
assert_executable "$TARGET/scripts/ai-preflight.sh"
assert_executable "$TARGET/scripts/drift-guard.sh"
assert_executable "$TARGET/scripts/risk-report.sh"
assert_executable "$TARGET/scripts/task-closeout.sh"

say "DEMO_STEP generated_files_verified"

preflight_output="$(cd "$TARGET" && bash scripts/ai-preflight.sh T-000)"
assert_contains "$preflight_output" "PRECHECK"
assert_contains "$preflight_output" "current_task: T-000"
assert_contains "$preflight_output" "task_card: docs/tasks/T-000.md"

say "DEMO_STEP preflight_passed"
print_matching_lines "$preflight_output" '^(PRECHECK|current_task: T-000|task_card: docs/tasks/T-000.md)$'

drift_output="$(cd "$TARGET" && bash scripts/drift-guard.sh)"
assert_contains "$drift_output" "TASK_CARD_LINT_PASS"
assert_contains "$drift_output" "PLAN_GUARD_PASS"
assert_contains "$drift_output" "SECRETS_GUARD_PASS"
assert_contains "$drift_output" "DRIFT_GUARD_PASS"
assert_file "$TARGET/reports/ai-risk/T-000-risk-report.md"
assert_file "$TARGET/reports/ai-risk/T-000-risk-report.json"
assert_contains "$(cat "$TARGET/reports/ai-risk/T-000-risk-report.md")" "- overall_risk:"

say "DEMO_STEP drift_and_risk_checked"
print_matching_lines "$drift_output" '^(TASK_CARD_LINT_PASS|PLAN_GUARD_PASS|SECRETS_GUARD_PASS|DRIFT_GUARD_PASS)$'
say "risk_report: reports/ai-risk/T-000-risk-report.md"

git -C "$TARGET" add .
git -C "$TARGET" \
  -c user.name="Vibecoding Demo" \
  -c user.email="vibecoding-demo@example.invalid" \
  -c commit.gpgsign=false \
  commit -m "T-000: initialize generated project demo" >/dev/null

commit_subject="$(git -C "$TARGET" log -1 --pretty='commit_subject: %s')"
assert_contains "$commit_subject" "commit_subject: T-000: initialize generated project demo"

say "DEMO_STEP commit_checkpoint_created"
say "$commit_subject"

closeout_output="$(cd "$TARGET" && bash scripts/task-closeout.sh T-000 --no-tests --write-report)"
assert_contains "$closeout_output" "CLOSEOUT"
assert_contains "$closeout_output" "plan_guard: PLAN_GUARD_PASS S-001"
assert_contains "$closeout_output" "risk_report: reports/ai-risk/T-000-risk-report.md"
assert_contains "$closeout_output" "git_checkpoint: COMMIT_CHECKPOINT"
assert_contains "$closeout_output" "closeout_report: reports/ai-closeout/T-000.md"
assert_file "$TARGET/reports/ai-closeout/T-000.md"
assert_contains "$(cat "$TARGET/reports/ai-closeout/T-000.md")" "- plan_guard: PLAN_GUARD_PASS S-001"
assert_contains "$(cat "$TARGET/reports/ai-closeout/T-000.md")" "## Risk Report"

say "DEMO_STEP closeout_report_written"
print_matching_lines "$closeout_output" '^(CLOSEOUT|plan_guard: PLAN_GUARD_PASS S-001|risk_report: reports/ai-risk/T-000-risk-report.md|git_checkpoint: COMMIT_CHECKPOINT|closeout_report: reports/ai-closeout/T-000.md)'

say "DEMO_PASS"
