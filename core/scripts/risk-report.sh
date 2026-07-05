#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
. scripts/plan-lib.sh

task="${1:-}"
[[ "$task" =~ ^T-[0-9]{3}$ ]] || {
  echo "RISK_REPORT_FAIL: missing or invalid task id" >&2
  exit 2
}

step="${2:-$(state_get current_step)}"
report_dir="reports/ai-risk"
md_report="${report_dir}/${task}-risk-report.md"
json_report="${report_dir}/${task}-risk-report.json"

severity_rank() {
  case "$1" in
    LOW) printf '1\n' ;;
    MEDIUM) printf '2\n' ;;
    HIGH) printf '3\n' ;;
    CRITICAL) printf '4\n' ;;
    *) printf '0\n' ;;
  esac
}

json_escape() {
  local value="${1:-}"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  value="${value//$'\r'/\\r}"
  value="${value//$'\t'/\\t}"
  printf '%s' "$value"
}

classify_file() {
  local file="$1"

  case "$file" in
    .env|.env.*|*.pem|*.key|id_rsa|id_ed25519|*/id_rsa|*/id_ed25519)
      printf 'CRITICAL|secret_path|secret or credential path\n'
      ;;
    pom.xml|package.json|package-lock.json|pnpm-lock.yaml|yarn.lock|Dockerfile)
      printf 'HIGH|dependency_or_build|dependency or build surface change\n'
      ;;
    .github/workflows/*|.gitcode/workflows/*)
      printf 'HIGH|ci_workflow|ci workflow change\n'
      ;;
    src/main/resources/application*.yml|src/main/resources/application*.yaml)
      printf 'HIGH|runtime_config|runtime configuration change\n'
      ;;
    db/migration/*|db/migrations/*)
      printf 'HIGH|database_migration|database migration change\n'
      ;;
    scripts/*|docs/policies/*|prompts/*|AGENTS.md|CLAUDE.md|GEMINI.md|.windsurfrules|.clinerules|.cursor/*|.roo/*|.github/copilot-instructions.md)
      printf 'MEDIUM|governance_surface|governance or automation surface change\n'
      ;;
    src/*|test/*|tests/*|docs/*|reports/*|README.md)
      printf 'LOW|normal_task_surface|normal task surface change\n'
      ;;
    *)
      printf 'MEDIUM|unclassified_path|path is outside known low-risk buckets\n'
      ;;
  esac
}

mkdir -p "$report_dir"

mapfile -t files < <(changed_files)

overall_risk="LOW"
decision="review_optional"
changed_count=0
md_body=""
json_entries=""
first_json=true

for file in "${files[@]}"; do
  [[ -n "$file" ]] || continue
  changed_count=$((changed_count + 1))
  IFS='|' read -r file_risk category reason < <(classify_file "$file")

  if [[ "$(severity_rank "$file_risk")" -gt "$(severity_rank "$overall_risk")" ]]; then
    overall_risk="$file_risk"
  fi

  md_body+="- \`$file\`: $file_risk | $category | $reason"$'\n'

  escaped_file="$(json_escape "$file")"
  escaped_reason="$(json_escape "$reason")"
  escaped_category="$(json_escape "$category")"
  if [[ "$first_json" == true ]]; then
    first_json=false
  else
    json_entries+=","
  fi
  json_entries+=$'\n'"    {\"path\":\"${escaped_file}\",\"risk\":\"${file_risk}\",\"category\":\"${escaped_category}\",\"reason\":\"${escaped_reason}\"}"
done

if [[ "$(severity_rank "$overall_risk")" -ge "$(severity_rank "HIGH")" ]]; then
  decision="review_required"
fi

if [[ "$changed_count" -eq 0 ]]; then
  md_body="- none"$'\n'
fi

cat >"$md_report" <<EOF
# AI Risk Report - $task

## Context

- task: $task
- step: ${step:-unknown}
- changed_files: $changed_count

## Summary

- overall_risk: $overall_risk
- decision: $decision

## Changed Files

${md_body}
EOF

cat >"$json_report" <<EOF
{
  "task": "$(json_escape "$task")",
  "step": "$(json_escape "${step:-unknown}")",
  "changed_files_count": $changed_count,
  "overall_risk": "$overall_risk",
  "decision": "$decision",
  "changed_files": [${json_entries}
  ]
}
EOF

echo "RISK_REPORT_WRITTEN"
echo "task: $task"
echo "step: ${step:-unknown}"
echo "overall_risk: $overall_risk"
echo "decision: $decision"
echo "markdown_report: $md_report"
echo "json_report: $json_report"
