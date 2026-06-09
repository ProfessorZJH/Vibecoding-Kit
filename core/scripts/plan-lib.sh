#!/usr/bin/env bash

plan_task_file() {
  local task="${1:-}"
  [[ -n "$task" ]] || return 2
  printf 'docs/tasks/%s.md\n' "$task"
}

plan_file() {
  local task="${1:-}"
  [[ -n "$task" ]] || return 2
  printf 'docs/plans/%s-plan.md\n' "$task"
}

state_get() {
  local key="${1:-}"
  [[ -n "$key" ]] || return 2
  [[ -f docs/AI_STATE.yml ]] || return 0

  awk -F: -v key="$key" '
    $1 == key {
      v = substr($0, index($0, ":") + 1)
      gsub(/^[ \t]+|[ \t]+$/, "", v)
      print v
      exit
    }
  ' docs/AI_STATE.yml 2>/dev/null || true
}

state_set() {
  local key="${1:-}"
  local value="${2:-}"
  local tmp

  [[ -n "$key" ]] || return 2
  tmp="$(mktemp)"

  if awk -v key="$key" -v value="$value" '
    BEGIN { done = 0 }
    index($0, key ":") == 1 {
      print key ": " value
      done = 1
      next
    }
    { print }
    END {
      if (done == 0) print key ": " value
    }
  ' docs/AI_STATE.yml >"$tmp"; then
    mv "$tmp" docs/AI_STATE.yml
  else
    rm -f "$tmp"
    return 1
  fi
}

plan_hash() {
  local file="${1:-}"
  [[ -n "$file" ]] || return 2
  awk '!/^status:[[:space:]]/ { print }' "$file" | sha256sum | awk '{ print $1 }'
}

changed_files() {
  {
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      if git rev-parse --verify HEAD >/dev/null 2>&1; then
        git diff --name-only HEAD
      else
        git diff --name-only
      fi
      git diff --cached --name-only
      git ls-files --others --exclude-standard
    fi
  } 2>/dev/null | sed '/^$/d' | sort -u
}

step_block() {
  local file="${1:-}"
  local step="${2:-}"
  [[ -n "$file" && -n "$step" ]] || return 2

  awk -v step="$step" '
    $0 ~ "^## " step " " { in_step = 1; print; next }
    in_step && /^## S-[0-9][0-9][0-9] / { exit }
    in_step { print }
  ' "$file"
}

step_field() {
  local file="${1:-}"
  local step="${2:-}"
  local field="${3:-}"
  [[ -n "$file" && -n "$step" && -n "$field" ]] || return 2

  step_block "$file" "$step" | awk -v field="$field" '
    $0 == field ":" { in_field = 1; next }
    in_field && (/^## / || /^[a-z_]+:/) { exit }
    in_field && /^- / {
      line = $0
      sub(/^- /, "", line)
      print line
    }
  '
}

step_status() {
  local file="${1:-}"
  local step="${2:-}"
  [[ -n "$file" && -n "$step" ]] || return 2

  step_block "$file" "$step" | awk -F: '
    $1 == "status" {
      v = substr($0, index($0, ":") + 1)
      gsub(/^[ \t]+|[ \t]+$/, "", v)
      print v
      exit
    }
  '
}

path_matches_pattern() {
  local file="${1:-}"
  local pattern="${2:-}"

  [[ -n "$file" && -n "$pattern" ]] || return 1
  [[ "$pattern" == "**" ]] && return 0

  if [[ "$pattern" == *"/**" ]]; then
    local prefix="${pattern%/**}"
    [[ "$file" == "$prefix" || "$file" == "$prefix/"* ]] && return 0
  elif [[ "$pattern" == *"*"* ]]; then
    [[ "$file" == $pattern ]] && return 0
  else
    [[ "$file" == "$pattern" ]] && return 0
  fi

  return 1
}

file_allowed_by_step() {
  local plan="${1:-}"
  local step="${2:-}"
  local file="${3:-}"
  local pattern

  [[ -n "$plan" && -n "$step" && -n "$file" ]] || return 2
  while IFS= read -r pattern; do
    [[ -n "$pattern" ]] || continue
    path_matches_pattern "$file" "$pattern" && return 0
  done < <(step_field "$plan" "$step" "allowed_changes")

  return 1
}

file_forbidden_by_step() {
  local plan="${1:-}"
  local step="${2:-}"
  local file="${3:-}"
  local pattern

  [[ -n "$plan" && -n "$step" && -n "$file" ]] || return 2
  while IFS= read -r pattern; do
    [[ -n "$pattern" ]] || continue
    path_matches_pattern "$file" "$pattern" && return 0
  done < <(step_field "$plan" "$step" "forbidden_changes")

  return 1
}

first_step() {
  local file="${1:-}"
  [[ -n "$file" ]] || return 2
  awk '/^## S-[0-9][0-9][0-9] / { print $2; exit }' "$file"
}

next_step_after() {
  local file="${1:-}"
  local current="${2:-}"
  [[ -n "$file" && -n "$current" ]] || return 2

  awk -v current="$current" '
    /^## S-[0-9][0-9][0-9] / {
      if (seen == 1) {
        print $2
        exit
      }
      if ($2 == current) seen = 1
    }
  ' "$file"
}
