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

for guard in scripts/*-guard.sh; do
  [[ -x "$guard" ]] || continue
  [[ "$guard" == "scripts/drift-guard.sh" ]] && continue
  bash "$guard"
done

if ! git diff --check >/tmp/vibecoding-kit-diff-check.out 2>/tmp/vibecoding-kit-diff-check.err; then
  record_failure "git diff --check" "$(cat /tmp/vibecoding-kit-diff-check.err)"
fi

if [[ "$failures" -gt 0 ]]; then
  exit 1
fi

echo "DRIFT_GUARD_PASS"
