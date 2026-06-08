#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

dry_run=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) dry_run=true ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done

hooks_dir="$(git rev-parse --git-dir)/hooks"

if [[ "$dry_run" == true ]]; then
  cat <<EOF
HOOK_INSTALL_DRY_RUN
target_dir: $hooks_dir
hooks:
  - pre-commit
  - pre-push
EOF
  exit 0
fi

mkdir -p "$hooks_dir"

cat >"$hooks_dir/pre-commit" <<'HOOK'
#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"
bash scripts/drift-guard.sh
git diff --check --cached
echo "PRE_COMMIT_GUARD_PASS"
HOOK

cat >"$hooks_dir/pre-push" <<'HOOK'
#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"
branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ -n "$(git status --short)" ]]; then
  echo "NO_PUSH_CHECKPOINT uncommitted_changes" >&2
  exit 1
fi
if [[ "$branch" =~ ^(main|master)$ && "${ALLOW_PROTECTED_BRANCH_PUSH:-false}" != "true" ]]; then
  echo "NO_PUSH_CHECKPOINT protected_branch_requires_approval" >&2
  exit 1
fi
bash scripts/drift-guard.sh
echo "PRE_PUSH_GUARD_PASS"
HOOK

chmod +x "$hooks_dir/pre-commit" "$hooks_dir/pre-push"
echo "HOOK_INSTALL_PASS"
