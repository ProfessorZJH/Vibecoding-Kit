#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FIXTURE_DIR="$ROOT_DIR/examples/java-service-governance-demo/fixture"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

TARGET="$TMP_DIR/java-service-governance-demo"

say() {
  printf '%s\n' "$*"
}

fail() {
  printf 'DEMO_FAIL: %s\n' "$*" >&2
  exit 1
}

assert_file() {
  [[ -f "$1" ]] || fail "missing file: $1"
}

assert_contains() {
  local text="$1"
  local expected="$2"

  [[ "$text" == *"$expected"* ]] ||
    fail "expected output to contain: $expected"
}

plan_hash() {
  awk '!/^status:[[:space:]]/ { print }' "$1" | sha256sum | awk '{ print $1 }'
}

set_ai_state_value() {
  local key="$1"
  local value="$2"
  local state_file="$TARGET/docs/AI_STATE.yml"
  local tmp="$TMP_DIR/AI_STATE.${key}.tmp"

  awk -v key="$key" -v value="$value" '
    BEGIN { done = 0 }
    $0 ~ "^" key ":" {
      print key ": " value
      done = 1
      next
    }
    { print }
    END {
      if (done == 0) print key ": " value
    }
  ' "$state_file" >"$tmp"
  mv "$tmp" "$state_file"
}

git_commit_all() {
  local message="$1"

  git -C "$TARGET" add .
  git -C "$TARGET" \
    -c user.name="Vibecoding Demo" \
    -c user.email="vibecoding-demo@example.invalid" \
    -c commit.gpgsign=false \
    commit -m "$message" >/dev/null
}

apply_service_change() {
  local service_file="$TARGET/src/main/java/com/example/order/OrderService.java"
  local tmp="$TMP_DIR/OrderService.java"

  awk '
    /return orderId.trim\(\);/ {
      print "    if (orderId == null || orderId.isBlank()) {"
      print "      throw new IllegalArgumentException(\"orderId is required\");"
      print "    }"
      print "    return orderId.trim();"
      next
    }
    { print }
  ' "$service_file" >"$tmp"
  mv "$tmp" "$service_file"
}

apply_runtime_config_change() {
  cat >>"$TARGET/src/main/resources/application.yml" <<'YAML'

orders:
  validation-mode: relaxed
YAML
}

mkdir -p "$TARGET"
cp -R "$FIXTURE_DIR"/. "$TARGET"/
cp -R "$ROOT_DIR/core/scripts" "$TARGET/scripts"
find "$TARGET/scripts" -type f -name '*.sh' -exec chmod +x {} +
cp "$TARGET/docs/tasks/T-010-demo.md" "$TARGET/docs/tasks/T-010.md"

hash="$(plan_hash "$TARGET/docs/plans/T-010-plan.md")"
set_ai_state_value "plan_hash" "$hash"

GIT_CONFIG_COUNT=1 \
GIT_CONFIG_KEY_0=init.defaultBranch \
GIT_CONFIG_VALUE_0=master \
git -C "$TARGET" init >/dev/null

git_commit_all "T-010: initialize java service governance demo"

assert_file "$TARGET/pom.xml"
assert_file "$TARGET/src/main/java/com/example/order/OrderService.java"
assert_file "$TARGET/src/main/java/com/example/order/OrderController.java"
assert_file "$TARGET/src/main/resources/application.yml"
assert_file "$TARGET/docs/tasks/T-010.md"
assert_file "$TARGET/docs/plans/T-010-plan.md"

say "DEMO_STEP fixture_prepared"

set_ai_state_value "require_plan_guard" "true"
apply_service_change

service_guard_output="$(cd "$TARGET" && bash scripts/plan-guard.sh T-010 S-001)"
assert_contains "$service_guard_output" "PLAN_GUARD_PASS"

say "DEMO_STEP service_change_allowed"
printf '%s\n' "$service_guard_output" | rg '^(PLAN_GUARD_PASS|current_task: T-010|current_step: S-001)$'

apply_runtime_config_change

if unauthorized_output="$(cd "$TARGET" && bash scripts/plan-guard.sh T-010 S-001 2>&1)"; then
  fail "plan guard should reject runtime configuration drift"
fi
assert_contains "$unauthorized_output" "PLAN_GUARD_FAIL: unauthorized file"
assert_contains "$unauthorized_output" "src/main/resources/application.yml"

say "DEMO_STEP unauthorized_file_detected"
printf '%s\n' "$unauthorized_output" |
  rg '^(PLAN_GUARD_FAIL: unauthorized file|src/main/resources/application.yml)$'

risk_output="$(cd "$TARGET" && bash scripts/risk-report.sh T-010)"
assert_contains "$risk_output" "RISK_REPORT_WRITTEN"
assert_contains "$risk_output" "overall_risk: HIGH"
assert_file "$TARGET/reports/ai-risk/T-010-risk-report.md"
assert_file "$TARGET/reports/ai-risk/T-010-risk-report.json"
assert_contains \
  "$(cat "$TARGET/reports/ai-risk/T-010-risk-report.md")" \
  "src/main/resources/application.yml"

say "DEMO_STEP runtime_config_change_detected"
printf '%s\n' "$risk_output" | rg '^overall_risk: HIGH$'

set_ai_state_value "require_plan_guard" "false"
if closeout_output="$(cd "$TARGET" && bash scripts/task-closeout.sh T-010 --no-tests --write-report 2>&1)"; then
  fail "closeout should report unauthorized files for the demo state"
fi
assert_contains "$closeout_output" "CLOSEOUT"
assert_contains "$closeout_output" "src/main/resources/application.yml"
assert_contains "$closeout_output" "overall_risk: HIGH"
assert_contains "$closeout_output" "closeout_report: reports/ai-closeout/T-010.md"
assert_file "$TARGET/reports/ai-closeout/T-010.md"
assert_contains \
  "$(cat "$TARGET/reports/ai-closeout/T-010.md")" \
  "src/main/resources/application.yml"

say "DEMO_STEP closeout_report_written"
printf '%s\n' "$closeout_output" |
  rg '^(CLOSEOUT|src/main/resources/application.yml|overall_risk: HIGH|closeout_report: reports/ai-closeout/T-010.md)$'

say "DEMO_PASS"
