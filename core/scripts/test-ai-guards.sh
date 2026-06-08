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

for file in scripts/ai-preflight.sh scripts/drift-guard.sh scripts/task-closeout.sh scripts/install-git-hooks.sh; do
  [[ -x "$file" ]] || fail "$file missing or not executable"
done

preflight="$(bash scripts/ai-preflight.sh T-000)"
assert_contains "$preflight" "PRECHECK"
assert_contains "$preflight" "current_task: T-000"

drift="$(bash scripts/drift-guard.sh)"
assert_contains "$drift" "DRIFT_GUARD_PASS"

closeout="$(bash scripts/task-closeout.sh T-000 --no-tests)"
assert_contains "$closeout" "CLOSEOUT"
assert_contains "$closeout" "git_checkpoint:"

hooks="$(bash scripts/install-git-hooks.sh --dry-run)"
assert_contains "$hooks" "HOOK_INSTALL_DRY_RUN"

echo "AI_GUARD_TESTS_PASS"
