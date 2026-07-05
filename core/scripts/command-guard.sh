#!/usr/bin/env bash
set -euo pipefail

command_input="${1:-}"
risk="LOW"
decision="allow"
reason="read-only or known safe command"

print_result() {
  local status="$1"
  printf '%s\n' "$status"
  printf 'command: %s\n' "${command_input:-<missing>}"
  printf 'risk: %s\n' "$risk"
  printf 'decision: %s\n' "$decision"
  printf 'reason: %s\n' "$reason"
}

allow() {
  risk="$1"
  decision="allow"
  reason="$2"
}

approval() {
  risk="$1"
  decision="require_approval"
  reason="$2"
}

block() {
  risk="$1"
  decision="block"
  reason="$2"
}

if [[ -z "$command_input" ]]; then
  block "HIGH" "missing command input"
  print_result "COMMAND_GUARD_FAIL"
  exit 2
fi

if [[ "$command_input" == *'`'* || "$command_input" == *'$('* ]]; then
  block "CRITICAL" "command injection pattern detected"
elif [[ "$command_input" =~ curl[[:space:]].*\|[[:space:]]*(bash|sh) ]]; then
  block "CRITICAL" "remote script execution"
elif [[ "$command_input" =~ wget[[:space:]].*\|[[:space:]]*(bash|sh) ]]; then
  block "CRITICAL" "remote script execution"
elif [[ "$command_input" =~ (^|[[:space:]])sudo([[:space:]]|$) ]]; then
  block "CRITICAL" "sudo command"
elif [[ "$command_input" =~ (^|[[:space:]])rm[[:space:]]+-rf[[:space:]]+/($|[[:space:]]) ]]; then
  block "CRITICAL" "destructive root deletion"
elif [[ "$command_input" =~ chmod[[:space:]]+777([[:space:]]|$) ]]; then
  block "CRITICAL" "broad permission change"
elif [[ "$command_input" =~ cat[[:space:]]+(\./)?\.env([[:space:]]|$) ]]; then
  block "CRITICAL" "secret file read"
elif [[ "$command_input" =~ cat[[:space:]]+~/.ssh/ ]]; then
  block "CRITICAL" "ssh credential read"
elif [[ "$command_input" =~ cat[[:space:]]+~/.aws/credentials ]]; then
  block "CRITICAL" "cloud credential read"
elif [[ "$command_input" =~ (^|[[:space:]])(npm|pnpm|yarn)[[:space:]]+install([[:space:]]|$) ]]; then
  approval "HIGH" "dependency install"
elif [[ "$command_input" =~ (^|[[:space:]])mvn[[:space:]]+clean[[:space:]]+package([[:space:]]|$) ]]; then
  approval "HIGH" "build packaging changes local state"
elif [[ "$command_input" =~ docker[[:space:]]+compose[[:space:]]+up([[:space:]]|$) ]]; then
  approval "HIGH" "docker compose changes local runtime state"
elif [[ "$command_input" =~ docker[[:space:]]+build([[:space:]]|$) ]]; then
  approval "HIGH" "docker image build"
elif [[ "$command_input" =~ (^|[[:space:]])(pytest|go[[:space:]]+test|mvn([[:space:]]+-q)?[[:space:]]+test|npm[[:space:]]+test|pnpm[[:space:]]+test)([[:space:]]|$) ]]; then
  allow "MEDIUM" "test command"
else
  allow "LOW" "read-only or unclassified local command"
fi

if [[ "$decision" == "block" ]]; then
  print_result "COMMAND_GUARD_FAIL"
  exit 1
fi

print_result "COMMAND_GUARD_PASS"
