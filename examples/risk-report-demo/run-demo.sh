#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

TARGET="$TMP_DIR/risk-report-demo-project"

say() {
  printf '%s\n' "$*"
}

assert_file() {
  [[ -f "$1" ]] || {
    printf 'DEMO_FAIL: missing file: %s\n' "$1" >&2
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

git_commit_all() {
  local message="$1"

  git -C "$TARGET" add .
  git -C "$TARGET" \
    -c user.name="Vibecoding Demo" \
    -c user.email="vibecoding-demo@example.invalid" \
    -c commit.gpgsign=false \
    commit -m "$message" >/dev/null
}

GIT_CONFIG_COUNT=1 \
GIT_CONFIG_KEY_0=init.defaultBranch \
GIT_CONFIG_VALUE_0=master \
bash "$ROOT_DIR/installer/init.sh" \
  --target "$TARGET" \
  --name risk-report-demo \
  --profile agent-adapters \
  --ci none >/dev/null

git_commit_all "T-000: initialize risk report demo"

mkdir -p "$TARGET/src/main/resources"
cat >"$TARGET/src/main/resources/application.yml" <<'YAML'
demo:
  runtime-config: changed
YAML

say "DEMO_STEP runtime_config_changed"

risk_output="$(cd "$TARGET" && bash scripts/risk-report.sh T-000)"
assert_contains "$risk_output" "RISK_REPORT_WRITTEN"
assert_contains "$risk_output" "overall_risk: HIGH"
assert_file "$TARGET/reports/ai-risk/T-000-risk-report.md"
assert_file "$TARGET/reports/ai-risk/T-000-risk-report.json"
assert_contains "$(cat "$TARGET/reports/ai-risk/T-000-risk-report.md")" "- overall_risk: HIGH"
assert_contains "$(cat "$TARGET/reports/ai-risk/T-000-risk-report.md")" 'src/main/resources/application.yml'

say "DEMO_STEP risk_report_written"
printf '%s\n' "$risk_output" | rg '^overall_risk: HIGH$'
say "DEMO_PASS"
