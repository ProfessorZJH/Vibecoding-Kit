#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

TARGET="$TMP_DIR/target-adapter.md"
TEMPLATE="$TMP_DIR/template-adapter.md"

say() {
  printf '%s\n' "$*"
}

assert_contains() {
  local text="$1"
  local expected="$2"

  [[ "$text" == *"$expected"* ]] || {
    printf 'DEMO_FAIL: expected output to contain: %s\n' "$expected" >&2
    exit 1
  }
}

assert_not_contains() {
  local text="$1"
  local unexpected="$2"

  [[ "$text" != *"$unexpected"* ]] || {
    printf 'DEMO_FAIL: expected output not to contain: %s\n' "$unexpected" >&2
    exit 1
  }
}

cat >"$TARGET" <<'EOF'
user header
<!-- VIBECODING-KIT:BEGIN -->
old kit content
<!-- VIBECODING-KIT:END -->
user footer
EOF

cat >"$TEMPLATE" <<'EOF'
template header
<!-- VIBECODING-KIT:BEGIN -->
new kit content
<!-- VIBECODING-KIT:END -->
template footer
EOF

check_output="$(bash "$ROOT_DIR/core/scripts/adapter-block.sh" --check "$TARGET")"
assert_contains "$check_output" "ADAPTER_BLOCK_PASS"
say "DEMO_STEP check_valid_block"
printf '%s\n' "$check_output"

update_output="$(bash "$ROOT_DIR/core/scripts/adapter-block.sh" --update "$TARGET" "$TEMPLATE")"
assert_contains "$update_output" "ADAPTER_BLOCK_UPDATED"
say "DEMO_STEP update_managed_block"
printf '%s\n' "$update_output"

updated_target="$(cat "$TARGET")"
assert_contains "$updated_target" "user header"
assert_contains "$updated_target" "user footer"
assert_contains "$updated_target" "new kit content"
assert_not_contains "$updated_target" "old kit content"
assert_not_contains "$updated_target" "template header"
assert_not_contains "$updated_target" "template footer"

say "DEMO_STEP user_content_preserved"
say "DEMO_PASS"
