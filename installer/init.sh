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

usage() {
  cat <<EOF
Usage: bash installer/init.sh --target PATH --name NAME [options]

Options:
  --profile NAME           Add profile: ddd, finance, java-spring, vue
  --ci NAME                Add CI workflow: none, gitcode, github
  --group-id VALUE         Maven groupId for optional scaffold
  --version VALUE          Maven version for optional scaffold
  --package VALUE          Java package for optional scaffold
  --apply-xfg-scaffold     Copy XFG archetype resources into project root with basic substitution
  --install-hooks          Install Git hooks after initialization
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

replace_project_name() {
  find "$target" -type f \
    ! -path '*/.git/*' \
    -exec sed -i "s/__PROJECT_NAME__/${name}/g" {} +
}

copy_tree "$KIT_ROOT/core" "$target"
replace_project_name

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

find "$target/scripts" -type f -name '*.sh' -exec chmod +x {} +

if [[ ! -d "$target/.git" ]]; then
  git -C "$target" init >/dev/null
fi

if [[ "$install_hooks" == true ]]; then
  (cd "$target" && bash scripts/install-git-hooks.sh)
fi

cat <<EOF
VIBECODING_KIT_INIT_PASS
target: $target
project: $name
profiles: ${profiles[*]:-none}
ci: ${cis[*]:-none}
EOF
