#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() {
  printf 'READABILITY_GUARD_FAIL: %s\n' "$*" >&2
  exit 1
}

assert_file() {
  [[ -f "$1" ]] || fail "missing file: $1"
}

check_min_lines() {
  local file="$1"
  local minimum="$2"
  local actual

  assert_file "$file"
  actual="$(wc -l <"$file")"
  [[ "$actual" -ge "$minimum" ]] ||
    fail "$file has $actual lines, expected at least $minimum"
}

check_max_line_length() {
  local file="$1"
  local maximum="$2"
  local output

  assert_file "$file"
  output="$(
    awk -v max="$maximum" '
      length($0) > max {
        printf "%s:%d: line length %d exceeds %d\n",
          FILENAME, FNR, length($0), max
      }
    ' "$file"
  )"

  [[ -z "$output" ]] || fail "$output"
}

check_bash_syntax() {
  local file="$1"

  assert_file "$file"
  bash -n "$file" || fail "bash syntax check failed: $file"
}

markdown_files=(
  README.md
  examples/README.md
  CHANGELOG.md
  docs/releases/v0.7.0.md
  docs/releases/v0.8.0.md
  docs/tasks/T-007.md
  docs/tasks/T-008.md
  docs/tasks/T-009.md
  docs/tasks/T-010.md
  docs/tasks/T-011.md
  docs/plans/T-008-plan.md
  docs/plans/T-009-plan.md
  docs/plans/T-010-plan.md
  docs/plans/T-011-plan.md
)

shell_files=(
  installer/init.sh
  scripts/test-kit.sh
  scripts/readability-guard.sh
  examples/generated-project-demo/run-demo.sh
)

optional_shell_files=(
  examples/installer-ux-demo/run-demo.sh
)

check_min_lines README.md 80
check_min_lines examples/README.md 10
check_min_lines CHANGELOG.md 20
check_min_lines installer/init.sh 100
check_min_lines scripts/test-kit.sh 200
check_min_lines scripts/readability-guard.sh 50
check_min_lines docs/tasks/T-011.md 30
check_min_lines docs/plans/T-011-plan.md 30

for file in "${markdown_files[@]}"; do
  check_max_line_length "$file" 180
done

for file in "${shell_files[@]}"; do
  check_max_line_length "$file" 240
  check_bash_syntax "$file"
done

for file in "${optional_shell_files[@]}"; do
  if [[ -f "$file" ]]; then
    check_max_line_length "$file" 240
    check_bash_syntax "$file"
  fi
done

echo "READABILITY_GUARD_PASS"
