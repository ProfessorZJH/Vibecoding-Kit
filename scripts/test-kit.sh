#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() {
  echo "TEST_FAIL: $*" >&2
  exit 1
}

assert_file() {
  [[ -f "$1" ]] || fail "missing file: $1"
}

assert_dir() {
  [[ -d "$1" ]] || fail "missing directory: $1"
}

assert_executable() {
  [[ -x "$1" ]] || fail "missing executable: $1"
}

assert_contains() {
  local text="$1"
  local expected="$2"
  [[ "$text" == *"$expected"* ]] || fail "expected output to contain: $expected"
}

assert_not_contains() {
  local text="$1"
  local unexpected="$2"
  [[ "$text" != *"$unexpected"* ]] || fail "expected output not to contain: $unexpected"
}

assert_count() {
  local text="$1"
  local expected="$2"
  local count="$3"
  local actual
  actual="$(printf '%s\n' "$text" | rg -c "^${expected}$" || true)"
  [[ "$actual" == "$count" ]] || fail "expected $expected count $count, got $actual"
}

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

MVP_TARGET="$TMP_DIR/mvp-project"
FULL_TARGET="$TMP_DIR/full-project"
XFG_TARGET="$TMP_DIR/xfg-project"

help_text="$(bash installer/init.sh --help)"
assert_contains "$help_text" "api-contract"

bash installer/init.sh \
  --target "$MVP_TARGET" \
  --name mvp-demo \
  --profile ddd \
  --profile finance \
  --ci none \
  --write-report

assert_file "$MVP_TARGET/AGENTS.md"
assert_file "$MVP_TARGET/CLAUDE.md"
assert_file "$MVP_TARGET/docs/AI_STATE.yml"
assert_file "$MVP_TARGET/docs/AI_RULES_VERSION.yml"
assert_contains "$(cat "$MVP_TARGET/docs/AI_RULES_VERSION.yml")" "installed_at: "
assert_not_contains "$(cat "$MVP_TARGET/docs/AI_RULES_VERSION.yml")" "__INSTALLED_AT__"
assert_contains "$(cat "$MVP_TARGET/docs/AI_RULES_VERSION.yml")" "  - ddd"
assert_contains "$(cat "$MVP_TARGET/docs/AI_RULES_VERSION.yml")" "  - finance"
assert_file "$MVP_TARGET/docs/tasks/T-000.md"
assert_file "$MVP_TARGET/reports/vibecoding-init.md"
assert_contains "$(cat "$MVP_TARGET/reports/vibecoding-init.md")" "bash scripts/ai-preflight.sh T-000"
assert_file "$MVP_TARGET/docs/DDD_STYLE.md"
assert_file "$MVP_TARGET/docs/FINANCE_RULES.md"
assert_file "$MVP_TARGET/docs/reference/xfg-ddd-scaffold-lite-jdk17/archetype-resources/pom.xml"
assert_executable "$MVP_TARGET/scripts/ai-preflight.sh"
assert_executable "$MVP_TARGET/scripts/task-closeout.sh"
assert_executable "$MVP_TARGET/scripts/drift-guard.sh"
assert_executable "$MVP_TARGET/scripts/task-card-lint.sh"
assert_executable "$MVP_TARGET/scripts/secrets-guard.sh"
assert_executable "$MVP_TARGET/scripts/architecture-guard.sh"
assert_executable "$MVP_TARGET/scripts/finance-guard.sh"

mvp_preflight="$(cd "$MVP_TARGET" && bash scripts/ai-preflight.sh T-000)"
assert_contains "$mvp_preflight" "PRECHECK"
assert_contains "$mvp_preflight" "current_task: T-000"

mvp_drift="$(cd "$MVP_TARGET" && bash scripts/drift-guard.sh)"
assert_contains "$mvp_drift" "DRIFT_GUARD_PASS"
assert_contains "$mvp_drift" "TASK_CARD_LINT_PASS"
assert_contains "$mvp_drift" "SECRETS_GUARD_PASS"
assert_count "$mvp_drift" "SECRETS_GUARD_PASS" "1"

bad_task="$MVP_TARGET/docs/tasks/T-999.md"
printf '# T-999 Missing Sections\n' >"$bad_task"
if (cd "$MVP_TARGET" && bash scripts/task-card-lint.sh T-999) >/tmp/vibecoding-kit-task-card.out 2>&1; then
  fail "task-card-lint should reject incomplete task card"
fi
rm -f "$bad_task"

printf 'api_key=THIS_IS_A_FAKE_SECRET_VALUE_12345\n' >"$MVP_TARGET/leaked.env"
if (cd "$MVP_TARGET" && bash scripts/secrets-guard.sh) >/tmp/vibecoding-kit-secrets.out 2>&1; then
  fail "secrets-guard should reject fake secret content"
fi
rm -f "$MVP_TARGET/leaked.env"

mvp_closeout="$(cd "$MVP_TARGET" && bash scripts/task-closeout.sh T-000 --no-tests --write-report)"
assert_contains "$mvp_closeout" "CLOSEOUT"
assert_contains "$mvp_closeout" "closeout_report: reports/ai-closeout/T-000.md"
assert_file "$MVP_TARGET/reports/ai-closeout/T-000.md"

bash installer/init.sh \
  --target "$XFG_TARGET" \
  --name xfg-demo \
  --profile ddd \
  --apply-xfg-scaffold \
  --ci none

assert_file "$XFG_TARGET/pom.xml"
assert_dir "$XFG_TARGET/xfg-demo-api"
assert_dir "$XFG_TARGET/xfg-demo-app"
assert_dir "$XFG_TARGET/xfg-demo-domain"
assert_dir "$XFG_TARGET/xfg-demo-infrastructure"
assert_dir "$XFG_TARGET/xfg-demo-trigger"
assert_dir "$XFG_TARGET/xfg-demo-types"
assert_file "$XFG_TARGET/docs/reference/xfg-ddd-scaffold-lite-jdk17/archetype-resources/pom.xml"

bash installer/init.sh \
  --target "$FULL_TARGET" \
  --name full-demo \
  --profile java-spring \
  --profile vue \
  --profile ddd \
  --profile finance \
  --profile api-contract \
  --ci gitcode \
  --ci github \
  --write-report

assert_file "$FULL_TARGET/.gitcode/workflows/ai-guard.yml"
assert_file "$FULL_TARGET/.github/workflows/ai-guard.yml"
assert_file "$FULL_TARGET/docs/API_SPEC.md"
assert_file "$FULL_TARGET/docs/API_STYLE.md"
assert_contains "$(cat "$FULL_TARGET/docs/AI_RULES_VERSION.yml")" "  - api-contract"
assert_file "$FULL_TARGET/docs/JAVA_SPRING_STYLE.md"
assert_file "$FULL_TARGET/docs/VUE_STYLE.md"
assert_file "$FULL_TARGET/reports/vibecoding-init.md"
assert_contains "$(cat "$FULL_TARGET/reports/vibecoding-init.md")" "- api-contract"
assert_contains "$(cat "$FULL_TARGET/reports/vibecoding-init.md")" "bash scripts/task-closeout.sh T-000 --no-tests --write-report"
assert_executable "$FULL_TARGET/scripts/api-contract-lint.sh"
assert_executable "$FULL_TARGET/scripts/api-contract-guard.sh"
assert_executable "$FULL_TARGET/scripts/java-spring-guard.sh"
assert_executable "$FULL_TARGET/scripts/vue-guard.sh"

full_test="$(cd "$FULL_TARGET" && bash scripts/test-ai-guards.sh)"
assert_contains "$full_test" "AI_GUARD_TESTS_PASS"

full_drift="$(cd "$FULL_TARGET" && bash scripts/drift-guard.sh)"
assert_contains "$full_drift" "API_CONTRACT_LINT_PASS"
assert_count "$full_drift" "SECRETS_GUARD_PASS" "1"

full_api_lint="$(cd "$FULL_TARGET" && bash scripts/api-contract-lint.sh T-000)"
assert_contains "$full_api_lint" "API_CONTRACT_LINT_PASS"

full_hook="$(cd "$FULL_TARGET" && bash scripts/install-git-hooks.sh --dry-run)"
assert_contains "$full_hook" "HOOK_INSTALL_DRY_RUN"

echo "KIT_TESTS_PASS"
