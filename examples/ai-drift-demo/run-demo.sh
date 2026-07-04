#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

TARGET="$TMP_DIR/drift-demo-project"
TASK="T-001"
STEP="S-001"

say() {
  printf '%s\n' "$*"
}

write_task_artifacts() {
  mkdir -p \
    "$TARGET/docs/tasks" \
    "$TARGET/docs/specs" \
    "$TARGET/docs/designs" \
    "$TARGET/docs/plans"

  cat >"$TARGET/docs/tasks/${TASK}.md" <<'TASK'
# T-001 Add Order Query Service

## Goal

Add an order query service without changing runtime configuration.

## Background

This demo shows how Vibecoding Kit blocks an AI agent when it edits files
outside the locked plan step allowlist.

## Allowed Changes

- src/main/java/com/example/order/OrderQueryService.java
- docs/AI_STATE.yml
- docs/plans/T-001-plan.md
- reports/ai-closeout/**

## Forbidden Changes

- .env*
- target/**
- node_modules/**

## Plan Contract

- requirements: `docs/specs/T-001-requirements.md`
- design: `docs/designs/T-001-design.md`
- plan: `docs/plans/T-001-plan.md`
- current_step: S-001

## Required Work

- Create the order query service.
- Demonstrate that configuration changes are blocked until the plan is updated.
- Write a closeout report.

## Forbidden Actions

- Do not bypass plan guard.
- Do not treat a native AI todo list as the source of truth.

## Test Requirements

- `bash scripts/spec-lint.sh T-001`
- `bash scripts/plan-guard.sh T-001 S-001`
- `bash scripts/task-closeout.sh T-001 --no-tests --write-report`

## Completion Criteria

- Unauthorized configuration edit is blocked.
- Updated plan is relocked.
- Closeout report is written.

## Risk

low
TASK

  cat >"$TARGET/docs/specs/${TASK}-requirements.md" <<'REQ'
# T-001 Requirements

status: approved

## Problem

AI agents sometimes edit runtime configuration while implementing a narrow code
task.

## Goals

- Show unauthorized configuration edits being blocked.
- Show how to update and relock the plan intentionally.

## Non-Goals

- Build a real order system.

## Acceptance Criteria

- `plan-guard.sh` reports `PLAN_GUARD_FAIL: unauthorized file`.
- The unauthorized path is `src/main/resources/application.yml`.
- After the plan is updated and relocked, closeout succeeds.

## Risk

low
REQ

  cat >"$TARGET/docs/designs/${TASK}-design.md" <<'DESIGN'
# T-001 Design

status: approved

## Architecture

Use a minimal Java service file as the allowed implementation target. Use
`src/main/resources/application.yml` as the intentional out-of-plan change.

## Files

- src/main/java/com/example/order/OrderQueryService.java: allowed service file
- src/main/resources/application.yml: initially unauthorized configuration file

## Data Flow

- Lock plan with service-only allowlist.
- Create service and configuration changes.
- Verify configuration change is blocked.
- Add configuration path to the plan and relock.

## Error Handling

- unauthorized file: `plan-guard.sh` must fail.

## Testing

- bash scripts/spec-lint.sh T-001
- bash scripts/plan-guard.sh T-001 S-001
- bash scripts/task-closeout.sh T-001 --no-tests --write-report
DESIGN

  cat >"$TARGET/docs/plans/${TASK}-plan.md" <<'PLAN'
# T-001 Plan

status: draft

## S-001 Add Order Query Service

status: pending

allowed_changes:
- src/main/java/com/example/order/OrderQueryService.java

forbidden_changes:
- .env*
- target/**
- node_modules/**

commands:
- bash scripts/spec-lint.sh T-001
- bash scripts/plan-guard.sh T-001 S-001
- bash scripts/task-closeout.sh T-001 --no-tests --write-report

expected:
- SPEC_LINT_PASS
- PLAN_GUARD_PASS
- CLOSEOUT

commit:
- required
PLAN
}

git_commit_all() {
  local message="$1"
  git -C "$TARGET" add .
  git -C "$TARGET" \
    -c user.name="Vibecoding Demo" \
    -c user.email="vibecoding-demo@example.invalid" \
    -c commit.gpgsign=false \
    commit -m "$message" >/dev/null
}

update_plan_to_allow_config() {
  awk '
    { print }
    $0 == "- src/main/java/com/example/order/OrderQueryService.java" {
      print "- src/main/resources/application.yml"
    }
  ' "$TARGET/docs/plans/${TASK}-plan.md" >"$TARGET/docs/plans/${TASK}-plan.md.tmp"
  mv "$TARGET/docs/plans/${TASK}-plan.md.tmp" "$TARGET/docs/plans/${TASK}-plan.md"
}

update_task_to_allow_config() {
  awk '
    { print }
    $0 == "- src/main/java/com/example/order/OrderQueryService.java" {
      print "- src/main/resources/application.yml"
    }
  ' "$TARGET/docs/tasks/${TASK}.md" >"$TARGET/docs/tasks/${TASK}.md.tmp"
  mv "$TARGET/docs/tasks/${TASK}.md.tmp" "$TARGET/docs/tasks/${TASK}.md"
}

GIT_CONFIG_COUNT=1 \
GIT_CONFIG_KEY_0=init.defaultBranch \
GIT_CONFIG_VALUE_0=master \
bash "$ROOT_DIR/installer/init.sh" \
  --target "$TARGET" \
  --name drift-demo \
  --profile agent-adapters \
  --ci none >/dev/null

git_commit_all "T-000: initialize drift demo"
write_task_artifacts

(cd "$TARGET" && bash scripts/spec-lint.sh "$TASK") >/dev/null
(cd "$TARGET" && bash scripts/plan-lock.sh "$TASK") >/dev/null
git_commit_all "T-001: lock service-only plan"

(cd "$TARGET" && bash scripts/plan-step.sh "$TASK" "$STEP" --start) >/dev/null

mkdir -p \
  "$TARGET/src/main/java/com/example/order" \
  "$TARGET/src/main/resources"

cat >"$TARGET/src/main/java/com/example/order/OrderQueryService.java" <<'JAVA'
package com.example.order;

public class OrderQueryService {
    public String findById(String orderId) {
        return "order:" + orderId;
    }
}
JAVA

cat >"$TARGET/src/main/resources/application.yml" <<'YAML'
order:
  query:
    timeout-ms: 3000
YAML

if guard_output="$(cd "$TARGET" && bash scripts/plan-guard.sh "$TASK" "$STEP" 2>&1)"; then
  say "DEMO_FAIL: unauthorized change was not blocked"
  exit 1
fi

say "DEMO_STEP unauthorized_change_blocked"
printf '%s\n' "$guard_output"

update_plan_to_allow_config
update_task_to_allow_config
(cd "$TARGET" && bash scripts/plan-lock.sh "$TASK") >/dev/null
git -C "$TARGET" add docs/AI_STATE.yml "docs/tasks/${TASK}.md" "docs/plans/${TASK}-plan.md"
git -C "$TARGET" \
  -c user.name="Vibecoding Demo" \
  -c user.email="vibecoding-demo@example.invalid" \
  -c commit.gpgsign=false \
  commit -m "T-001: relock plan for config change" >/dev/null

say "DEMO_STEP relocked_after_plan_update"

(cd "$TARGET" && bash scripts/plan-guard.sh "$TASK" "$STEP") >/dev/null
git -C "$TARGET" add src/main/java/com/example/order/OrderQueryService.java src/main/resources/application.yml
git -C "$TARGET" \
  -c user.name="Vibecoding Demo" \
  -c user.email="vibecoding-demo@example.invalid" \
  -c commit.gpgsign=false \
  commit -m "T-001: implement order query service" >/dev/null

(cd "$TARGET" && bash scripts/plan-step.sh "$TASK" "$STEP" --complete) >/dev/null
closeout_output="$(cd "$TARGET" && bash scripts/task-closeout.sh "$TASK" --no-tests --write-report)"

say "DEMO_STEP closeout_report_written"
printf '%s\n' "$closeout_output" | rg '^closeout_report: '
say "DEMO_PASS"
