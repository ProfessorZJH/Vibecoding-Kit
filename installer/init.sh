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
dry_run=false

usage() {
  cat <<EOF
Usage: bash installer/init.sh --target PATH --name NAME [options]

Options:
  --dry-run                Preview the install plan without writing the target
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
    --dry-run)
      dry_run=true ;;
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

target_input="$target"
case "$target_input" in
  /*) target_abs="$target_input" ;;
  *) target_abs="$(pwd)/$target_input" ;;
esac

tmp_root="$(mktemp -d)"
trap 'rm -rf "$tmp_root"' EXIT
staging="$tmp_root/staging"
mkdir -p "$staging"

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

yaml_scalar_or_default() {
  local file="$1"
  local key="$2"
  local default="$3"
  local value=""

  if [[ -f "$file" ]]; then
    value="$(awk -v key="$key" '
      $0 ~ "^" key ":[[:space:]]*" {
        sub("^[^:]*:[[:space:]]*", "", $0)
        print
        exit
      }
    ' "$file")"
  fi

  if [[ -n "$value" && "$value" != __*__ ]]; then
    printf '%s\n' "$value"
  else
    printf '%s\n' "$default"
  fi
}

replace_project_name() {
  find "$staging" -type f \
    ! -path '*/.git/*' \
    -exec sed -i "s/__PROJECT_NAME__/${name}/g" {} +
}

replace_initial_plan_hash() {
  local state_file="$staging/docs/AI_STATE.yml"
  local plan_file="$staging/docs/plans/T-000-plan.md"
  local hash

  [[ -f "$state_file" && -f "$plan_file" ]] || return 0
  hash="$(plan_hash "$plan_file")"
  sed -i "s/__PLAN_HASH__/${hash}/g" "$state_file"
}

profiles_text() {
  if [[ "${#profiles[@]}" -eq 0 ]]; then
    printf 'none\n'
  else
    printf '%s\n' "${profiles[*]}"
  fi
}

ci_text() {
  if [[ "${#cis[@]}" -eq 0 ]]; then
    printf 'none\n'
  else
    printf '%s\n' "${cis[*]}"
  fi
}

replace_profiles_list() {
  local version_file="$staging/docs/AI_RULES_VERSION.yml"
  local profiles_tmp="$tmp_root/profiles.yml"

  [[ -f "$version_file" ]] || return 0
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
}

build_payload() {
  local installed_at
  local source_commit
  local existing_version_file="$target_abs/docs/AI_RULES_VERSION.yml"
  local src
  local rel
  local out

  copy_tree "$KIT_ROOT/core" "$staging"
  replace_project_name

  installed_at="$(
    yaml_scalar_or_default \
      "$existing_version_file" \
      "installed_at" \
      "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  )"
  source_commit="$(
    yaml_scalar_or_default \
      "$existing_version_file" \
      "source_commit" \
      "$(git -C "$KIT_ROOT" rev-parse --short HEAD 2>/dev/null || echo unknown)"
  )"
  sed -i \
    -e "s/__INSTALLED_AT__/${installed_at}/g" \
    -e "s/__SOURCE_COMMIT__/${source_commit}/g" \
    "$staging/docs/AI_RULES_VERSION.yml"

  mkdir -p "$staging/docs/tasks" "$staging/reports/ai-closeout"

  for profile in "${profiles[@]}"; do
    case "$profile" in
      ddd)
        copy_tree "$KIT_ROOT/profiles/ddd/docs" "$staging/docs"
        copy_tree "$KIT_ROOT/profiles/ddd/scripts" "$staging/scripts"
        mkdir -p "$staging/docs/reference/xfg-ddd-scaffold-lite-jdk17"
        copy_tree \
          "$KIT_ROOT/profiles/ddd/xfg-archetype" \
          "$staging/docs/reference/xfg-ddd-scaffold-lite-jdk17"
        ;;
      finance)
        copy_tree "$KIT_ROOT/profiles/finance/docs" "$staging/docs"
        copy_tree "$KIT_ROOT/profiles/finance/scripts" "$staging/scripts"
        ;;
      api-contract)
        copy_tree "$KIT_ROOT/profiles/api-contract/docs" "$staging/docs"
        copy_tree "$KIT_ROOT/profiles/api-contract/scripts" "$staging/scripts"
        ;;
      agent-adapters)
        copy_tree "$KIT_ROOT/profiles/agent-adapters/root" "$staging"
        copy_tree "$KIT_ROOT/profiles/agent-adapters/docs" "$staging/docs"
        ;;
      java-spring)
        copy_tree "$KIT_ROOT/profiles/java-spring/docs" "$staging/docs"
        copy_tree "$KIT_ROOT/profiles/java-spring/scripts" "$staging/scripts"
        ;;
      vue)
        copy_tree "$KIT_ROOT/profiles/vue/docs" "$staging/docs"
        copy_tree "$KIT_ROOT/profiles/vue/scripts" "$staging/scripts"
        ;;
      "")
        ;;
      *)
        echo "unknown profile: $profile" >&2
        exit 2
        ;;
    esac
  done

  replace_profiles_list

  if [[ "$apply_xfg" == true ]]; then
    src="$KIT_ROOT/profiles/ddd/xfg-archetype/archetype-resources"
    [[ -d "$src" ]] || { echo "XFG archetype resources missing" >&2; exit 1; }
    while IFS= read -r dir; do
      rel="${dir#$src/}"
      [[ "$rel" == "$dir" ]] && rel=""
      out="$staging/${rel//__rootArtifactId__/$name}"
      mkdir -p "$out"
    done < <(find "$src" -type d)
    while IFS= read -r file; do
      rel="${file#$src/}"
      out="$staging/${rel//__rootArtifactId__/$name}"
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
        mkdir -p "$staging/.gitcode/workflows"
        cp \
          "$KIT_ROOT/core/workflows/gitcode/ai-guard.yml" \
          "$staging/.gitcode/workflows/ai-guard.yml"
        ;;
      github)
        mkdir -p "$staging/.github/workflows"
        cp \
          "$KIT_ROOT/core/workflows/github/ai-guard.yml" \
          "$staging/.github/workflows/ai-guard.yml"
        ;;
      *)
        echo "unknown ci: $ci" >&2
        exit 2
        ;;
    esac
  done

  replace_initial_plan_hash

  if [[ -d "$staging/scripts" ]]; then
    find "$staging/scripts" -type f -name '*.sh' -exec chmod +x {} +
  fi

  if [[ "$write_report" == true ]]; then
    mkdir -p "$staging/reports"
    {
      echo "# Vibecoding Init Report"
      echo
      echo "## Project"
      echo
      echo "- name: $name"
      echo "- target: $target_abs"
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
    } >"$staging/reports/vibecoding-init.md"
  fi
}

relpath_from_staging() {
  local path="$1"
  local rel="${path#$staging/}"
  [[ "$rel" == "$path" ]] && rel="${path#$staging}"
  printf '%s\n' "$rel"
}

plan_install() {
  create_file="$tmp_root/will_create"
  skip_file="$tmp_root/will_skip_existing"
  conflict_file="$tmp_root/will_conflict"
  : >"$create_file"
  : >"$skip_file"
  : >"$conflict_file"

  while IFS= read -r dir; do
    local rel
    local dest

    rel="$(relpath_from_staging "$dir")"
    [[ -n "$rel" ]] || continue
    dest="$target_abs/$rel"

    if [[ -e "$dest" && ! -d "$dest" ]]; then
      printf '%s\n' "$rel" >>"$conflict_file"
    elif [[ ! -e "$dest" ]]; then
      printf '%s/\n' "$rel" >>"$create_file"
    fi
  done < <(find "$staging" -type d | sort)

  while IFS= read -r file; do
    local rel
    local dest

    rel="$(relpath_from_staging "$file")"
    dest="$target_abs/$rel"

    if [[ -f "$dest" ]]; then
      if cmp -s "$file" "$dest"; then
        printf '%s\n' "$rel" >>"$skip_file"
      else
        printf '%s\n' "$rel" >>"$conflict_file"
      fi
    elif [[ -e "$dest" ]]; then
      printf '%s\n' "$rel" >>"$conflict_file"
    else
      printf '%s\n' "$rel" >>"$create_file"
    fi
  done < <(find "$staging" -type f | sort)
}

print_list() {
  local file="$1"

  if [[ -s "$file" ]]; then
    sed 's/^/  /' "$file"
  else
    echo "  none"
  fi
}

print_plan() {
  echo "target: $target_abs"
  echo "project: $name"
  echo "profiles: $(profiles_text)"
  echo "ci: $(ci_text)"
  echo "will_create:"
  print_list "$create_file"
  echo "will_skip_existing:"
  print_list "$skip_file"
  echo "will_conflict:"
  print_list "$conflict_file"
}

merge_payload() {
  while IFS= read -r dir; do
    local rel

    rel="$(relpath_from_staging "$dir")"
    [[ -n "$rel" ]] || continue
    mkdir -p "$target_abs/$rel"
  done < <(find "$staging" -type d | sort)

  while IFS= read -r file; do
    local rel
    local dest

    rel="$(relpath_from_staging "$file")"
    dest="$target_abs/$rel"
    [[ -e "$dest" ]] && continue
    mkdir -p "$(dirname "$dest")"
    cp -p "$file" "$dest"
  done < <(find "$staging" -type f | sort)
}

build_payload
plan_install

if [[ "$dry_run" == true ]]; then
  echo "VIBECODING_KIT_DRY_RUN"
  print_plan
  echo "DRY_RUN_PASS"
  exit 0
fi

if [[ -s "$conflict_file" ]]; then
  echo "VIBECODING_KIT_INSTALL_CONFLICT" >&2
  echo "target: $target_abs" >&2
  echo "will_conflict:" >&2
  sed 's/^/  /' "$conflict_file" >&2
  exit 1
fi

mkdir -p "$target_abs"
target_abs="$(cd "$target_abs" && pwd)"
merge_payload

if [[ ! -d "$target_abs/.git" ]]; then
  git -C "$target_abs" init >/dev/null
fi

if [[ "$install_hooks" == true ]]; then
  (cd "$target_abs" && bash scripts/install-git-hooks.sh)
fi

cat <<EOF
VIBECODING_KIT_INIT_PASS
target: $target_abs
project: $name
profiles: $(profiles_text)
ci: $(ci_text)
EOF

if [[ -s "$skip_file" ]]; then
  echo "will_skip_existing:"
  print_list "$skip_file"
fi
