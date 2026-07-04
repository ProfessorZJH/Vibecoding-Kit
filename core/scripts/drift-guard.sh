#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

failures=0

record_failure() {
  failures=$((failures + 1))
  {
    echo "STYLE_DRIFT"
    echo "location: $1"
    echo "reason: $2"
    echo "verify: bash scripts/drift-guard.sh"
  } >&2
}

artifact_hits="$(git ls-files --others --cached --exclude-standard 2>/dev/null | rg '(^|/)(target|node_modules|\.m2home|\.idea)(/|$)|(^|/)\.env(\.|$)|\.pem$|\.key$|(^|/)id_rsa$|(^|/)id_ed25519$' || true)"
[[ -z "$artifact_hits" ]] || record_failure "forbidden files" "$artifact_hits"

current_task="$(awk -F: '$1 == "current_task" { v=$2; gsub(/^[ \t]+|[ \t]+$/, "", v); print v; exit }' docs/AI_STATE.yml 2>/dev/null || true)"

for guard in scripts/*-guard.sh; do
  [[ -x "$guard" ]] || continue
  [[ "$guard" == "scripts/drift-guard.sh" ]] && continue
  [[ "$guard" == "scripts/plan-guard.sh" ]] && continue
  [[ "$guard" == "scripts/secrets-guard.sh" ]] && continue
  bash "$guard"
done

if [[ "$current_task" =~ ^T-[0-9]{3}$ ]]; then
  bash scripts/task-card-lint.sh "$current_task"
fi

require_plan_guard="$(awk -F: '$1 == "require_plan_guard" { v=$2; gsub(/^[ \t]+|[ \t]+$/, "", v); print v; exit }' docs/AI_STATE.yml 2>/dev/null || true)"
current_step="$(awk -F: '$1 == "current_step" { v=$2; gsub(/^[ \t]+|[ \t]+$/, "", v); print v; exit }' docs/AI_STATE.yml 2>/dev/null || true)"
if [[ "$require_plan_guard" == "true" ]]; then
  if [[ "$current_task" =~ ^T-[0-9]{3}$ && "$current_step" =~ ^S-[0-9]{3}$ ]]; then
    bash scripts/plan-guard.sh "$current_task" "$current_step"
  else
    record_failure "plan guard" "missing current_task or current_step"
  fi
fi

bash scripts/secrets-guard.sh

if ! git diff --check >/tmp/vibecoding-kit-diff-check.out 2>/tmp/vibecoding-kit-diff-check.err; then
  record_failure "git diff --check" "$(cat /tmp/vibecoding-kit-diff-check.err)"
fi

if [[ "$failures" -gt 0 ]]; then
  exit 1
fi

echo "DRIFT_GUARD_PASS"
