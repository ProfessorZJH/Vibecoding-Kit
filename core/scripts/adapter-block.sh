#!/usr/bin/env bash
set -euo pipefail

BEGIN_MARKER='<!-- VIBECODING-KIT:BEGIN -->'
END_MARKER='<!-- VIBECODING-KIT:END -->'

usage() {
  cat <<EOF
Usage:
  bash scripts/adapter-block.sh --check ADAPTER_FILE
  bash scripts/adapter-block.sh --update ADAPTER_FILE TEMPLATE_FILE
EOF
}

fail_block() {
  printf 'ADAPTER_BLOCK_FAIL\n' >&2
  printf 'reason: %s\n' "$*" >&2
  exit 1
}

block_bounds() {
  local file="$1"
  local label="$2"
  local begin_count
  local end_count
  local begin_line
  local end_line

  [[ -f "$file" ]] || fail_block "$label file not found: $file"

  begin_count="$(grep -Fxc "$BEGIN_MARKER" "$file" || true)"
  end_count="$(grep -Fxc "$END_MARKER" "$file" || true)"

  [[ "$begin_count" == "1" ]] || fail_block "$label requires exactly one begin marker, found $begin_count: $file"
  [[ "$end_count" == "1" ]] || fail_block "$label requires exactly one end marker, found $end_count: $file"

  begin_line="$(grep -Fnx "$BEGIN_MARKER" "$file" | cut -d: -f1)"
  end_line="$(grep -Fnx "$END_MARKER" "$file" | cut -d: -f1)"

  [[ "$begin_line" -lt "$end_line" ]] || fail_block "$label begin marker must appear before end marker: $file"

  printf '%s %s\n' "$begin_line" "$end_line"
}

check_file() {
  local file="$1"

  block_bounds "$file" "adapter" >/dev/null
  printf 'ADAPTER_BLOCK_PASS\n'
  printf 'file: %s\n' "$file"
}

update_file() {
  local target="$1"
  local template="$2"
  local target_begin
  local target_end
  local template_begin
  local template_end
  local tmp

  read -r target_begin target_end < <(block_bounds "$target" "target")
  read -r template_begin template_end < <(block_bounds "$template" "template")

  tmp="$(mktemp "${target}.tmp.XXXXXX")"
  awk -v begin="$target_begin" 'NR < begin { print }' "$target" >"$tmp"
  awk -v begin="$template_begin" -v end="$template_end" 'NR >= begin && NR <= end { print }' "$template" >>"$tmp"
  awk -v end="$target_end" 'NR > end { print }' "$target" >>"$tmp"
  chmod --reference="$target" "$tmp" 2>/dev/null || true
  mv "$tmp" "$target"

  printf 'ADAPTER_BLOCK_UPDATED\n'
  printf 'target: %s\n' "$target"
  printf 'template: %s\n' "$template"
}

mode="${1:-}"

case "$mode" in
  --check)
    [[ $# -eq 2 ]] || {
      usage >&2
      exit 2
    }
    check_file "$2"
    ;;
  --update)
    [[ $# -eq 3 ]] || {
      usage >&2
      exit 2
    }
    update_file "$2" "$3"
    ;;
  -h|--help)
    usage
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
