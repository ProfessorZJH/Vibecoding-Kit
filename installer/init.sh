#!/usr/bin/env bash
set -euo pipefail

KIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

target=""
name=""
group_id="com.example"
version="1.0-SNAPSHOT"
package_name="com.example"
profiles=()
cis=()
apply_xfg=false
install_hooks=false
write_report=false

usage() {
  cat <<EOF
Usage: bash installer/init.sh --target PATH --name NAME [options]

Options:
  --profile NAME           Add profile: ddd, finance, java-spring, vue, api-contract, agent-adapters
  --ci NAME                Add CI workflow: none, gitcode, github
  --group-id VALUE         Maven groupId for optional scaffold
  --version VALUE          Maven version for optional scaffold
  --package VALUE          Java package for optional scaffold
  --apply-xfg-scaffold     Copy XFG archetype resources into project root with basic substitution
  --install-hooks          Install Git hooks after initialization
  --write-report           Write reports/vibecoding-init.md
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      shift; target="${1:-}" ;;
    --name)
      shift; name="${1:-}" ;;
    --profile)
      shift; profiles+=("${1:-}") ;;
    --ci)
      shift; cis+=("${1:-}") ;;
    --group-id)
      shift; group_id="${1:-}" ;;
    --version)
      shift; version="${1:-}" ;;
    --package)
      shift; package_name="${1:-}" ;;
    --apply-xfg-scaffold)
      apply_xfg=true ;;
    --install-hooks)
      install_hooks=true ;;
    --write-report)
      write_report=true ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

[[ -n "$target" ]] || { echo "--target is required" >&2; exit 2; }
[[ -n "$name" ]] || { echo "--name is required" >&2; exit 2; }

mkdir -p "$target"
target="$(cd "$target" && pwd)"

copy_tree() {
  local src="$1"
  local dest="$2"
  [[ -d "$src" ]] || return 0
  mkdir -p "$dest"
  cp -R "$src"/. "$dest"/
}

plan_hash() {
  local file="$1"
  awk '!/^status:[[:space:]]/ { print }' "$file" | sha256sum | awk '{ print $1 }'
}

replace_initial_plan_hash() {
  local state_file="$target/docs/AI_STATE.yml"
  local plan_file="$target/docs/plans/T-000-plan.md"
  local hash

  [[ -f "$state_file" && -f "$plan_file" ]] || return 0
  hash="$(plan_hash "$plan_file")"
  sed -i "s/__PLAN_HASH__/${hash}/g" "$state_file"
}

replace_project_name() {
  find "$target" -type f \
    ! -path '*/.git/*' \
    -exec sed -i "s/__PROJECT_NAME__/${name}/g" {} +
}

copy_tree "$KIT_ROOT/core" "$target"
replace_project_name

installed_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
source_commit="$(git -C "$KIT_ROOT" rev-parse --short HEAD 2>/dev/null || echo unknown)"
sed -i \
  -e "s/__INSTALLED_AT__/${installed_at}/g" \
  -e "s/__SOURCE_COMMIT__/${source_commit}/g" \
  "$target/docs/AI_RULES_VERSION.yml"

mkdir -p "$target/docs/tasks" "$target/reports/ai-closeout"

for profile in "${profiles[@]}"; do
  case "$profile" in
    ddd)
      copy_tree "$KIT_ROOT/profiles/ddd/docs" "$target/docs"
      copy_tree "$KIT_ROOT/profiles/ddd/scripts" "$target/scripts"
      mkdir -p "$target/docs/reference/xfg-ddd-scaffold-lite-jdk17"
      copy_tree "$KIT_ROOT/profiles/ddd/xfg-archetype" "$target/docs/reference/xfg-ddd-scaffold-lite-jdk17"
      ;;
    finance)
      copy_tree "$KIT_ROOT/profiles/finance/docs" "$target/docs"
      copy_tree "$KIT_ROOT/profiles/finance/scripts" "$target/scripts"
      ;;
    api-contract)
      copy_tree "$KIT_ROOT/profiles/api-contract/docs" "$target/docs"
      copy_tree "$KIT_ROOT/profiles/api-contract/scripts" "$target/scripts"
      ;;
    agent-adapters)
      copy_tree "$KIT_ROOT/profiles/agent-adapters/root" "$target"
      copy_tree "$KIT_ROOT/profiles/agent-adapters/docs" "$target/docs"
      ;;
    java-spring)
      copy_tree "$KIT_ROOT/profiles/java-spring/docs" "$target/docs"
      copy_tree "$KIT_ROOT/profiles/java-spring/scripts" "$target/scripts"
      ;;
    vue)
      copy_tree "$KIT_ROOT/profiles/vue/docs" "$target/docs"
      copy_tree "$KIT_ROOT/profiles/vue/scripts" "$target/scripts"
      ;;
    "")
      ;;
    *)
      echo "unknown profile: $profile" >&2
      exit 2
      ;;
  esac
done

version_file="$target/docs/AI_RULES_VERSION.yml"
profiles_tmp="$(mktemp)"
{
  echo "profiles:"
  echo "  - core"
  for profile in "${profiles[@]}"; do
    [[ -n "$profile" ]] && echo "  - $profile"
  done
} >"$profiles_tmp"
awk '
  BEGIN { replacing = 0 }
  /^profiles:/ { replacing = 1; while ((getline line < profiles_file) > 0) print line; next }
  replacing && /^  - / { next }
  { replacing = 0; print }
' profiles_file="$profiles_tmp" "$version_file" >"$version_file.tmp"
mv "$version_file.tmp" "$version_file"
rm -f "$profiles_tmp"

if [[ "$apply_xfg" == true ]]; then
  src="$KIT_ROOT/profiles/ddd/xfg-archetype/archetype-resources"
  [[ -d "$src" ]] || { echo "XFG archetype resources missing" >&2; exit 1; }
  while IFS= read -r dir; do
    rel="${dir#$src/}"
    [[ "$rel" == "$dir" ]] && rel=""
    out="$target/${rel//__rootArtifactId__/$name}"
    mkdir -p "$out"
  done < <(find "$src" -type d)
  while IFS= read -r file; do
    rel="${file#$src/}"
    out="$target/${rel//__rootArtifactId__/$name}"
    mkdir -p "$(dirname "$out")"
    sed \
      -e 's/${groupId}/'"${group_id}"'/g' \
      -e 's/${artifactId}/'"${name}"'/g' \
      -e 's/${rootArtifactId}/'"${name}"'/g' \
      -e 's/${version}/'"${version}"'/g' \
      -e 's/${package}/'"${package_name}"'/g' \
      "$file" >"$out"
  done < <(find "$src" -type f)
fi

for ci in "${cis[@]}"; do
  case "$ci" in
    none|"")
      ;;
    gitcode)
      mkdir -p "$target/.gitcode/workflows"
      cp "$KIT_ROOT/core/workflows/gitcode/ai-guard.yml" "$target/.gitcode/workflows/ai-guard.yml"
      ;;
    github)
      mkdir -p "$target/.github/workflows"
      cp "$KIT_ROOT/core/workflows/github/ai-guard.yml" "$target/.github/workflows/ai-guard.yml"
      ;;
    *)
      echo "unknown ci: $ci" >&2
      exit 2
      ;;
  esac
done

replace_initial_plan_hash

find "$target/scripts" -type f -name '*.sh' -exec chmod +x {} +

if [[ ! -d "$target/.git" ]]; then
  git -C "$target" init >/dev/null
fi

if [[ "$install_hooks" == true ]]; then
  (cd "$target" && bash scripts/install-git-hooks.sh)
fi

if [[ "$write_report" == true ]]; then
  mkdir -p "$target/reports"
  {
    echo "# Vibecoding Init Report"
    echo
    echo "## Project"
    echo
    echo "- name: $name"
    echo "- target: $target"
    echo "- installed_at: $installed_at"
    echo "- source_commit: $source_commit"
    echo
    echo "## Profiles"
    echo
    echo "- core"
    for profile in "${profiles[@]}"; do
      [[ -n "$profile" ]] && echo "- $profile"
    done
    echo
    echo "## CI"
    echo
    if [[ "${#cis[@]}" -eq 0 ]]; then
      echo "- none"
    else
      for ci in "${cis[@]}"; do
        echo "- $ci"
      done
    fi
    echo
    echo "## Prompt Modules"
    echo
    echo "- prompts/00-agent-contract.md"
    echo "- prompts/01-explore-readonly.md"
    echo "- prompts/02-plan-locked-task.md"
    echo "- prompts/03-implement-current-step.md"
    echo "- prompts/04-command-classifier.md"
    echo "- prompts/05-security-review.md"
    echo "- prompts/06-closeout-report.md"
    echo "- prompts/07-task-memory-summary.md"
    echo
    echo "## Next Commands"
    echo
    echo '```bash'
    echo 'bash scripts/ai-preflight.sh T-000'
    echo 'bash scripts/drift-guard.sh'
    echo 'bash scripts/task-closeout.sh T-000 --no-tests --write-report'
    echo '```'
  } >"$target/reports/vibecoding-init.md"
fi

cat <<EOF
VIBECODING_KIT_INIT_PASS
target: $target
project: $name
profiles: ${profiles[*]:-none}
ci: ${cis[*]:-none}
EOF
