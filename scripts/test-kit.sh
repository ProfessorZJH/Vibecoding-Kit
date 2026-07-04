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

set_ai_state_value() {
  local file="$1"
  local key="$2"
  local value="$3"
  local tmp="$TMP_DIR/AI_STATE.${key}.tmp"
  awk -v key="$key" -v value="$value" '
    BEGIN { done = 0 }
    $0 ~ "^" key ":" { print key ": " value; done = 1; next }
    { print }
    END { if (done == 0) print key ": " value }
  ' "$file" >"$tmp"
  mv "$tmp" "$file"
}

plan_hash() {
  awk '!/^status:[[:space:]]/ { print }' "$1" | sha256sum | awk '{ print $1 }'
}

MVP_TARGET="$TMP_DIR/mvp-project"
FULL_TARGET="$TMP_DIR/full-project"
XFG_TARGET="$TMP_DIR/xfg-project"

assert_dir "examples/ai-drift-demo"
assert_file "examples/ai-drift-demo/README.md"
assert_executable "examples/ai-drift-demo/run-demo.sh"
assert_file "examples/ai-drift-demo/expected-output.txt"
assert_file ".github/workflows/test-kit.yml"
assert_file "CHANGELOG.md"
assert_file "docs/releases/v0.1.0.md"

demo_output="$(bash examples/ai-drift-demo/run-demo.sh)"
assert_contains "$demo_output" "DEMO_STEP unauthorized_change_blocked"
assert_contains "$demo_output" "PLAN_GUARD_FAIL: unauthorized file"
assert_contains "$demo_output" "src/main/resources/application.yml"
assert_contains "$demo_output" "DEMO_STEP relocked_after_plan_update"
assert_contains "$demo_output" "DEMO_STEP closeout_report_written"
assert_contains "$demo_output" "DEMO_PASS"

help_text="$(bash installer/init.sh --help)"
assert_contains "$help_text" "api-contract"
assert_contains "$help_text" "agent-adapters"

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
assert_file "$MVP_TARGET/docs/VIBECODING_WORKFLOW.md"
assert_contains "$(cat "$MVP_TARGET/docs/AI_RULES_VERSION.yml")" "installed_at: "
assert_not_contains "$(cat "$MVP_TARGET/docs/AI_RULES_VERSION.yml")" "__INSTALLED_AT__"
assert_contains "$(cat "$MVP_TARGET/docs/AI_RULES_VERSION.yml")" "  - ddd"
assert_contains "$(cat "$MVP_TARGET/docs/AI_RULES_VERSION.yml")" "  - finance"
assert_file "$MVP_TARGET/docs/tasks/T-000.md"
assert_file "$MVP_TARGET/docs/CONSTITUTION.md"
assert_file "$MVP_TARGET/docs/specs/REQUIREMENTS_TEMPLATE.md"
assert_file "$MVP_TARGET/docs/designs/DESIGN_TEMPLATE.md"
assert_file "$MVP_TARGET/docs/plans/PLAN_TEMPLATE.md"
assert_file "$MVP_TARGET/docs/plans/T-000-plan.md"
assert_contains "$(cat "$MVP_TARGET/docs/AI_STATE.yml")" "require_plan_guard: true"
assert_contains "$(cat "$MVP_TARGET/docs/AI_STATE.yml")" "plan_status: locked"
assert_contains "$(cat "$MVP_TARGET/docs/AI_STATE.yml")" "current_step: S-001"
assert_not_contains "$(cat "$MVP_TARGET/docs/AI_STATE.yml")" "__PLAN_HASH__"
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
assert_executable "$MVP_TARGET/scripts/spec-lint.sh"
assert_executable "$MVP_TARGET/scripts/plan-lock.sh"
assert_executable "$MVP_TARGET/scripts/plan-guard.sh"
assert_executable "$MVP_TARGET/scripts/plan-step.sh"

mvp_preflight="$(cd "$MVP_TARGET" && bash scripts/ai-preflight.sh T-000)"
assert_contains "$mvp_preflight" "PRECHECK"
assert_contains "$mvp_preflight" "current_task: T-000"

mvp_drift="$(cd "$MVP_TARGET" && bash scripts/drift-guard.sh)"
assert_contains "$mvp_drift" "DRIFT_GUARD_PASS"
assert_contains "$mvp_drift" "PLAN_GUARD_PASS"
assert_contains "$mvp_drift" "TASK_CARD_LINT_PASS"
assert_contains "$mvp_drift" "SECRETS_GUARD_PASS"
assert_count "$mvp_drift" "SECRETS_GUARD_PASS" "1"

mvp_spec_lint="$(cd "$MVP_TARGET" && bash scripts/spec-lint.sh T-000)"
assert_contains "$mvp_spec_lint" "SPEC_LINT_PASS"

cp "$MVP_TARGET/docs/plans/T-000-plan.md" "$TMP_DIR/T-000-plan.status-good.md"
sed -i '0,/^status: locked$/s//status: banana/' "$MVP_TARGET/docs/plans/T-000-plan.md"
if (cd "$MVP_TARGET" && bash scripts/spec-lint.sh T-000) >"$TMP_DIR/spec-lint-plan-status.out" 2>&1; then
  fail "spec-lint should reject unsupported plan status"
fi
assert_contains "$(cat "$TMP_DIR/spec-lint-plan-status.out")" "SPEC_LINT_FAIL: unsupported plan status"
cp "$TMP_DIR/T-000-plan.status-good.md" "$MVP_TARGET/docs/plans/T-000-plan.md"

sed -i '0,/^status: pending$/s//status: banana/' "$MVP_TARGET/docs/plans/T-000-plan.md"
if (cd "$MVP_TARGET" && bash scripts/spec-lint.sh T-000) >"$TMP_DIR/spec-lint-step-status.out" 2>&1; then
  fail "spec-lint should reject unsupported step status"
fi
assert_contains "$(cat "$TMP_DIR/spec-lint-step-status.out")" "SPEC_LINT_FAIL: unsupported step status"
cp "$TMP_DIR/T-000-plan.status-good.md" "$MVP_TARGET/docs/plans/T-000-plan.md"

cp "$MVP_TARGET/docs/tasks/T-000.md" "$MVP_TARGET/docs/tasks/T-001.md"
sed -i 's/T-000/T-001/g' "$MVP_TARGET/docs/tasks/T-001.md"
cp "$MVP_TARGET/docs/plans/T-000-plan.md" "$MVP_TARGET/docs/plans/T-001-plan.md"
sed -i 's/T-000/T-001/g' "$MVP_TARGET/docs/plans/T-001-plan.md"
cp "$MVP_TARGET/docs/specs/REQUIREMENTS_TEMPLATE.md" "$MVP_TARGET/docs/specs/T-001-requirements.md"
sed -i 's/T-xxx/T-001/g; s/status: draft/status: approved/' "$MVP_TARGET/docs/specs/T-001-requirements.md"
cp "$MVP_TARGET/docs/designs/DESIGN_TEMPLATE.md" "$MVP_TARGET/docs/designs/T-001-design.md"
sed -i 's/T-xxx/T-001/g; s/status: draft/status: approved/' "$MVP_TARGET/docs/designs/T-001-design.md"
t001_spec_lint="$(cd "$MVP_TARGET" && bash scripts/spec-lint.sh T-001)"
assert_contains "$t001_spec_lint" "SPEC_LINT_PASS"

sed -i 's/status: approved/status: banana/' "$MVP_TARGET/docs/specs/T-001-requirements.md"
if (cd "$MVP_TARGET" && bash scripts/spec-lint.sh T-001) >"$TMP_DIR/spec-lint-requirements-status.out" 2>&1; then
  fail "spec-lint should reject unsupported requirements status"
fi
assert_contains "$(cat "$TMP_DIR/spec-lint-requirements-status.out")" "SPEC_LINT_FAIL: unsupported requirements status"
sed -i 's/status: banana/status: approved/' "$MVP_TARGET/docs/specs/T-001-requirements.md"

sed -i 's/status: approved/status: banana/' "$MVP_TARGET/docs/designs/T-001-design.md"
if (cd "$MVP_TARGET" && bash scripts/spec-lint.sh T-001) >"$TMP_DIR/spec-lint-design-status.out" 2>&1; then
  fail "spec-lint should reject unsupported design status"
fi
assert_contains "$(cat "$TMP_DIR/spec-lint-design-status.out")" "SPEC_LINT_FAIL: unsupported design status"
rm -f \
  "$MVP_TARGET/docs/tasks/T-001.md" \
  "$MVP_TARGET/docs/plans/T-001-plan.md" \
  "$MVP_TARGET/docs/specs/T-001-requirements.md" \
  "$MVP_TARGET/docs/designs/T-001-design.md"

mvp_plan_guard="$(cd "$MVP_TARGET" && bash scripts/plan-guard.sh T-000 S-001)"
assert_contains "$mvp_plan_guard" "PLAN_GUARD_PASS"

mvp_plan_guard_no_args="$(cd "$MVP_TARGET" && bash scripts/plan-guard.sh)"
assert_contains "$mvp_plan_guard_no_args" "PLAN_GUARD_PASS"

cp "$MVP_TARGET/docs/AI_STATE.yml" "$TMP_DIR/AI_STATE.yml.known-good"
cp "$MVP_TARGET/docs/plans/T-000-plan.md" "$TMP_DIR/T-000-plan.md.known-good"

mvp_plan_start="$(cd "$MVP_TARGET" && bash scripts/plan-step.sh T-000 S-001 --start)"
assert_contains "$mvp_plan_start" "PLAN_STEP_START"

if (cd "$MVP_TARGET" && bash scripts/plan-step.sh T-000 S-001 --complete) >"$TMP_DIR/plan-step-uncommitted.out" 2>&1; then
  fail "plan-step should reject required step completion without commit checkpoint"
fi
assert_contains "$(cat "$TMP_DIR/plan-step-uncommitted.out")" "PLAN_STEP_FAIL: commit required"

git -C "$MVP_TARGET" add .
git -C "$MVP_TARGET" \
  -c user.name="Vibecoding Kit Test" \
  -c user.email="vibecoding-kit-test@example.invalid" \
  -c commit.gpgsign=false \
  commit -m "T-000: verify initialized kit" >/dev/null

mvp_plan_complete="$(cd "$MVP_TARGET" && bash scripts/plan-step.sh T-000 S-001 --complete)"
assert_contains "$mvp_plan_complete" "PLAN_STEP_COMPLETE"

restore_plan_fixture() {
  cp "$TMP_DIR/AI_STATE.yml.known-good" "$MVP_TARGET/docs/AI_STATE.yml"
  cp "$TMP_DIR/T-000-plan.md.known-good" "$MVP_TARGET/docs/plans/T-000-plan.md"
  rm -f "$MVP_TARGET/unplanned.txt"
  assert_contains "$(cat "$MVP_TARGET/docs/AI_STATE.yml")" "plan_status: locked"
  assert_contains "$(cat "$MVP_TARGET/docs/AI_STATE.yml")" "current_step: S-001"
}

restore_plan_fixture
if [[ -n "$(git -C "$MVP_TARGET" status --porcelain)" ]]; then
  git -C "$MVP_TARGET" add .
  git -C "$MVP_TARGET" \
    -c user.name="Vibecoding Kit Test" \
    -c user.email="vibecoding-kit-test@example.invalid" \
    -c commit.gpgsign=false \
    commit -m "test fixture baseline" >/dev/null
fi

restore_plan_fixture
sed -i 's/plan_status: locked/plan_status: draft/' "$MVP_TARGET/docs/AI_STATE.yml"
if (cd "$MVP_TARGET" && bash scripts/plan-guard.sh T-000 S-001) >"$TMP_DIR/plan-unlocked.out" 2>&1; then
  fail "plan-guard should reject unlocked plan"
fi
assert_contains "$(cat "$TMP_DIR/plan-unlocked.out")" "PLAN_GUARD_FAIL: plan not locked"

restore_plan_fixture
if (cd "$MVP_TARGET" && bash scripts/plan-guard.sh T-000 S-999) >"$TMP_DIR/plan-step.out" 2>&1; then
  fail "plan-guard should reject wrong current step"
fi
assert_contains "$(cat "$TMP_DIR/plan-step.out")" "PLAN_STEP_FAIL: step is not current"
assert_contains "$(cat "$TMP_DIR/plan-step.out")" "requested: S-999"
assert_contains "$(cat "$TMP_DIR/plan-step.out")" "current: S-001"

restore_plan_fixture
if (cd "$MVP_TARGET" && bash scripts/plan-step.sh T-000 S-999 --start) >"$TMP_DIR/plan-step-command.out" 2>&1; then
  fail "plan-step should reject wrong current step"
fi
assert_contains "$(cat "$TMP_DIR/plan-step-command.out")" "PLAN_STEP_FAIL: step is not current"
assert_contains "$(cat "$TMP_DIR/plan-step-command.out")" "requested: S-999"
assert_contains "$(cat "$TMP_DIR/plan-step-command.out")" "current: S-001"

restore_plan_fixture
sed -i '0,/^- \*\*$/s//- docs\/AI_STATE.yml\n- docs\/plans\/T-000-plan.md/' "$MVP_TARGET/docs/plans/T-000-plan.md"
set_ai_state_value "$MVP_TARGET/docs/AI_STATE.yml" "plan_hash" "$(plan_hash "$MVP_TARGET/docs/plans/T-000-plan.md")"
printf 'drift\n' >"$MVP_TARGET/unplanned.txt"
if (cd "$MVP_TARGET" && bash scripts/plan-guard.sh T-000 S-001) >"$TMP_DIR/plan-drift.out" 2>&1; then
  fail "plan-guard should reject files outside current step allowlist"
fi
assert_contains "$(cat "$TMP_DIR/plan-drift.out")" "PLAN_GUARD_FAIL: unauthorized file"
restore_plan_fixture

restore_plan_fixture
printf '\nallowed_changes:\n- **\n' >>"$MVP_TARGET/docs/plans/T-000-plan.md"
if (cd "$MVP_TARGET" && bash scripts/plan-guard.sh T-000 S-001) >"$TMP_DIR/plan-hash.out" 2>&1; then
  fail "plan-guard should reject locked plan changes"
fi
assert_contains "$(cat "$TMP_DIR/plan-hash.out")" "PLAN_GUARD_FAIL: locked plan changed"
restore_plan_fixture

restore_plan_fixture
set_ai_state_value "$MVP_TARGET/docs/AI_STATE.yml" "plan_hash" "__PLAN_HASH__"
if (cd "$MVP_TARGET" && bash scripts/plan-guard.sh T-000 S-001) >"$TMP_DIR/plan-placeholder-hash.out" 2>&1; then
  fail "plan-guard should reject placeholder plan hash"
fi
assert_contains "$(cat "$TMP_DIR/plan-placeholder-hash.out")" "PLAN_GUARD_FAIL: missing or invalid plan_hash"
restore_plan_fixture

RENAME_TARGET="$TMP_DIR/rename-project"
mkdir -p "$RENAME_TARGET/old"
git -C "$RENAME_TARGET" init >/dev/null
printf 'baseline\n' >"$RENAME_TARGET/old/legacy.txt"
git -C "$RENAME_TARGET" add old/legacy.txt
git -C "$RENAME_TARGET" \
  -c user.name="Vibecoding Kit Test" \
  -c user.email="vibecoding-kit-test@example.invalid" \
  -c commit.gpgsign=false \
  commit -m "baseline" >/dev/null
mkdir -p "$RENAME_TARGET/allowed"
git -C "$RENAME_TARGET" mv old/legacy.txt allowed/new.txt
rename_changes="$(cd "$RENAME_TARGET" && . "$MVP_TARGET/scripts/plan-lib.sh" && changed_files)"
assert_contains "$rename_changes" "old/legacy.txt"
assert_contains "$rename_changes" "allowed/new.txt"

COPY_TARGET="$TMP_DIR/copy-project"
mkdir -p "$COPY_TARGET"
git -C "$COPY_TARGET" init >/dev/null
printf 'baseline\n' >"$COPY_TARGET/original.txt"
git -C "$COPY_TARGET" add original.txt
git -C "$COPY_TARGET" \
  -c user.name="Vibecoding Kit Test" \
  -c user.email="vibecoding-kit-test@example.invalid" \
  -c commit.gpgsign=false \
  commit -m "baseline" >/dev/null
cp "$COPY_TARGET/original.txt" "$COPY_TARGET/copied.txt"
git -C "$COPY_TARGET" add copied.txt
copy_changes="$(cd "$COPY_TARGET" && . "$MVP_TARGET/scripts/plan-lib.sh" && changed_files)"
assert_contains "$copy_changes" "original.txt"
assert_contains "$copy_changes" "copied.txt"

bad_task="$MVP_TARGET/docs/tasks/T-999.md"
printf '# T-999 Missing Sections\n' >"$bad_task"
if (cd "$MVP_TARGET" && bash scripts/task-card-lint.sh T-999) >"$TMP_DIR/task-card.out" 2>&1; then
  fail "task-card-lint should reject incomplete task card"
fi
rm -f "$bad_task"

printf 'api_key=THIS_IS_A_FAKE_SECRET_VALUE_12345\n' >"$MVP_TARGET/leaked.env"
if (cd "$MVP_TARGET" && bash scripts/secrets-guard.sh) >"$TMP_DIR/secrets.out" 2>&1; then
  fail "secrets-guard should reject fake secret content"
fi
rm -f "$MVP_TARGET/leaked.env"

mvp_closeout="$(cd "$MVP_TARGET" && bash scripts/task-closeout.sh T-000 --no-tests --write-report)"
assert_contains "$mvp_closeout" "CLOSEOUT"
assert_contains "$mvp_closeout" "plan_guard: PLAN_GUARD_PASS S-001"
assert_contains "$mvp_closeout" "closeout_report: reports/ai-closeout/T-000.md"
assert_file "$MVP_TARGET/reports/ai-closeout/T-000.md"
assert_contains "$(cat "$MVP_TARGET/reports/ai-closeout/T-000.md")" "- plan_guard: PLAN_GUARD_PASS S-001"

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
  --profile agent-adapters \
  --ci gitcode \
  --ci github \
  --write-report

assert_file "$FULL_TARGET/.gitcode/workflows/ai-guard.yml"
assert_file "$FULL_TARGET/.github/workflows/ai-guard.yml"
assert_file "$FULL_TARGET/docs/API_SPEC.md"
assert_file "$FULL_TARGET/docs/API_STYLE.md"
assert_contains "$(cat "$FULL_TARGET/docs/AI_RULES_VERSION.yml")" "  - api-contract"
assert_contains "$(cat "$FULL_TARGET/docs/AI_RULES_VERSION.yml")" "  - agent-adapters"
assert_file "$FULL_TARGET/docs/JAVA_SPRING_STYLE.md"
assert_file "$FULL_TARGET/docs/VUE_STYLE.md"
assert_file "$FULL_TARGET/docs/ai/PLAN_PROTOCOL.md"
assert_file "$FULL_TARGET/docs/ai/AGENT_COMPATIBILITY.md"
assert_file "$FULL_TARGET/docs/ai/CODEX_BRIDGE.md"
assert_file "$FULL_TARGET/docs/ai/CLAUDE_CODE_BRIDGE.md"
assert_file "$FULL_TARGET/docs/ai/SUPERPOWERS_BRIDGE.md"
assert_file "$FULL_TARGET/AGENTS.md"
assert_file "$FULL_TARGET/CLAUDE.md"
assert_file "$FULL_TARGET/GEMINI.md"
assert_file "$FULL_TARGET/.cursor/rules/vibecoding.mdc"
assert_file "$FULL_TARGET/.windsurfrules"
assert_file "$FULL_TARGET/.clinerules"
assert_file "$FULL_TARGET/.roo/rules/vibecoding.md"
assert_file "$FULL_TARGET/.github/copilot-instructions.md"
assert_contains "$(cat "$FULL_TARGET/docs/ai/PLAN_PROTOCOL.md")" "docs/tasks/T-xxx.md"
assert_contains "$(cat "$FULL_TARGET/docs/ai/PLAN_PROTOCOL.md")" "## Plan Engine"
assert_contains "$(cat "$FULL_TARGET/docs/ai/PLAN_PROTOCOL.md")" "bash scripts/ai-preflight.sh T-xxx"
assert_contains "$(cat "$FULL_TARGET/docs/ai/PLAN_PROTOCOL.md")" "bash scripts/plan-lock.sh T-xxx"
assert_contains "$(cat "$FULL_TARGET/docs/ai/PLAN_PROTOCOL.md")" "bash scripts/drift-guard.sh"
assert_contains "$(cat "$FULL_TARGET/docs/ai/PLAN_PROTOCOL.md")" "bash scripts/task-closeout.sh T-xxx --write-report"
assert_contains "$(cat "$FULL_TARGET/docs/ai/PLAN_PROTOCOL.md")" "PLAN_CHANGE_REQUIRED"
assert_contains "$(cat "$FULL_TARGET/docs/ai/PLAN_PROTOCOL.md")" "COMMIT_CHECKPOINT"
assert_contains "$(cat "$FULL_TARGET/docs/ai/SUPERPOWERS_BRIDGE.md")" "locked plan engine contract"
assert_contains "$(cat "$FULL_TARGET/docs/ai/CODEX_BRIDGE.md")" "locked plan engine contract"
assert_contains "$(cat "$FULL_TARGET/docs/ai/CLAUDE_CODE_BRIDGE.md")" "locked plan engine contract"
assert_contains "$(cat "$FULL_TARGET/AGENTS.md")" "docs/ai/PLAN_PROTOCOL.md"
assert_contains "$(cat "$FULL_TARGET/CLAUDE.md")" "docs/ai/PLAN_PROTOCOL.md"
assert_contains "$(cat "$FULL_TARGET/.cursor/rules/vibecoding.mdc")" "alwaysApply: true"
assert_file "$FULL_TARGET/reports/vibecoding-init.md"
assert_contains "$(cat "$FULL_TARGET/reports/vibecoding-init.md")" "- api-contract"
assert_contains "$(cat "$FULL_TARGET/reports/vibecoding-init.md")" "- agent-adapters"
assert_contains "$(cat "$FULL_TARGET/reports/vibecoding-init.md")" "bash scripts/task-closeout.sh T-000 --no-tests --write-report"
assert_executable "$FULL_TARGET/scripts/api-contract-lint.sh"
assert_executable "$FULL_TARGET/scripts/api-contract-guard.sh"
assert_executable "$FULL_TARGET/scripts/java-spring-guard.sh"
assert_executable "$FULL_TARGET/scripts/vue-guard.sh"
assert_contains "$(cat "$FULL_TARGET/scripts/test-ai-guards.sh")" "scripts/spec-lint.sh"
assert_contains "$(cat "$FULL_TARGET/scripts/test-ai-guards.sh")" "scripts/plan-lock.sh"
assert_contains "$(cat "$FULL_TARGET/scripts/test-ai-guards.sh")" "scripts/plan-guard.sh"
assert_contains "$(cat "$FULL_TARGET/scripts/test-ai-guards.sh")" "scripts/plan-step.sh"
assert_contains "$(cat "$FULL_TARGET/scripts/test-ai-guards.sh")" "plan_guard:"

full_test="$(cd "$FULL_TARGET" && bash scripts/test-ai-guards.sh)"
assert_contains "$full_test" "AI_GUARD_TESTS_PASS"

full_drift="$(cd "$FULL_TARGET" && bash scripts/drift-guard.sh)"
assert_contains "$full_drift" "API_CONTRACT_LINT_PASS"
assert_contains "$full_drift" "PLAN_GUARD_PASS"
assert_count "$full_drift" "SECRETS_GUARD_PASS" "1"

full_api_lint="$(cd "$FULL_TARGET" && bash scripts/api-contract-lint.sh T-000)"
assert_contains "$full_api_lint" "API_CONTRACT_LINT_PASS"

full_hook="$(cd "$FULL_TARGET" && bash scripts/install-git-hooks.sh --dry-run)"
assert_contains "$full_hook" "HOOK_INSTALL_DRY_RUN"

echo "KIT_TESTS_PASS"
