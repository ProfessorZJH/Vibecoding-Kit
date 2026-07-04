#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() {
  echo "TEST_FAIL: $*" >&2
  exit 1
}

assert_contains() {
  [[ "$1" == *"$2"* ]] || fail "expected output to contain: $2"
}

state_value() {
  local key="$1"
  awk -F: -v key="$key" '
    $1 == key {
      v = substr($0, index($0, ":") + 1)
      gsub(/^[ \t]+|[ \t]+$/, "", v)
      print v
      exit
    }
  ' "$2" 2>/dev/null || true
}

template_plan_hash="$(state_value plan_hash docs/AI_STATE.yml)"
template_source_commit="$(state_value source_commit docs/AI_RULES_VERSION.yml)"
if [[ "$template_plan_hash" == "__PLAN_HASH__" && "$template_source_commit" == "__SOURCE_COMMIT__" ]]; then
  state_backup="$(mktemp)"
  cp docs/AI_STATE.yml "$state_backup"
  trap 'cp "$state_backup" docs/AI_STATE.yml; rm -f "$state_backup"' EXIT
  computed_plan_hash="$(awk '!/^status:[[:space:]]/ { print }' docs/plans/T-000-plan.md | sha256sum | awk '{ print $1 }')"
  sed -i "s/__PLAN_HASH__/${computed_plan_hash}/g" docs/AI_STATE.yml
fi

for file in scripts/ai-preflight.sh scripts/drift-guard.sh scripts/task-closeout.sh scripts/install-git-hooks.sh scripts/task-card-lint.sh scripts/secrets-guard.sh scripts/spec-lint.sh scripts/plan-lock.sh scripts/plan-guard.sh scripts/plan-step.sh; do
  [[ -x "$file" ]] || fail "$file missing or not executable"
done

preflight="$(bash scripts/ai-preflight.sh T-000)"
assert_contains "$preflight" "PRECHECK"
assert_contains "$preflight" "current_task: T-000"

drift="$(bash scripts/drift-guard.sh)"
assert_contains "$drift" "DRIFT_GUARD_PASS"
assert_contains "$drift" "TASK_CARD_LINT_PASS"
assert_contains "$drift" "SECRETS_GUARD_PASS"
if [[ -x scripts/api-contract-guard.sh ]]; then
  assert_contains "$drift" "API_CONTRACT_LINT_PASS"
fi

task_lint="$(bash scripts/task-card-lint.sh T-000)"
assert_contains "$task_lint" "TASK_CARD_LINT_PASS"

spec_lint="$(bash scripts/spec-lint.sh T-000)"
assert_contains "$spec_lint" "SPEC_LINT_PASS"

plan_guard="$(bash scripts/plan-guard.sh T-000 S-001)"
assert_contains "$plan_guard" "PLAN_GUARD_PASS"

secrets_guard="$(bash scripts/secrets-guard.sh)"
assert_contains "$secrets_guard" "SECRETS_GUARD_PASS"

closeout="$(bash scripts/task-closeout.sh T-000 --no-tests)"
assert_contains "$closeout" "CLOSEOUT"
assert_contains "$closeout" "plan_guard:"
assert_contains "$closeout" "git_checkpoint:"

hooks="$(bash scripts/install-git-hooks.sh --dry-run)"
assert_contains "$hooks" "HOOK_INSTALL_DRY_RUN"

echo "AI_GUARD_TESTS_PASS"
