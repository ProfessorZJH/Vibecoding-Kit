# Plan Engine Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the plan-engine workflow so generated projects can lock a plan, execute only the current step, block plan drift, and report plan status during closeout.

**Architecture:** The implementation adds core templates, a small shell plan library, four plan-engine scripts, and closeout/drift integration. The plan file stays Markdown for human readability; shell scripts parse a strict subset of headings and list fields for deterministic checks.

**Tech Stack:** Bash, awk, sed, rg, git, markdown templates, existing vibecoding-kit installer and shell test suite.

---

## File Structure

Create:

- `core/docs/CONSTITUTION.md`: project-wide principles checked by humans and referenced by agents.
- `core/docs/specs/REQUIREMENTS_TEMPLATE.md`: requirements artifact template.
- `core/docs/designs/DESIGN_TEMPLATE.md`: design artifact template.
- `core/docs/plans/PLAN_TEMPLATE.md`: strict plan-step contract template.
- `core/docs/plans/T-000-plan.md`: generated initialization plan.
- `core/scripts/plan-lib.sh`: shared shell helpers for state, plan parsing, changed files, and path matching.
- `core/scripts/spec-lint.sh`: validates requirements/design/plan/task files.
- `core/scripts/plan-lock.sh`: validates and locks a task plan.
- `core/scripts/plan-guard.sh`: enforces current step, plan lock, plan hash, and changed-file allowlist.
- `core/scripts/plan-step.sh`: starts, completes, or blocks the current step.

Modify:

- `core/docs/AI_STATE.yml`: add plan-engine state fields with legacy-safe defaults.
- `core/docs/AI_RULES_INDEX.md`: document plan-engine startup and closeout.
- `core/docs/TASK_TEMPLATE.md`: add plan contract section.
- `core/docs/tasks/T-000.md`: reference `docs/plans/T-000-plan.md`.
- `core/scripts/drift-guard.sh`: call `plan-guard.sh` when enabled.
- `core/scripts/task-closeout.sh`: include plan guard result and fail when required plan guard fails.
- `core/scripts/test-ai-guards.sh`: assert new scripts and positive plan flow.
- `profiles/agent-adapters/docs/ai/PLAN_PROTOCOL.md`: make plan-engine mandatory when `require_plan_guard: true`.
- `profiles/agent-adapters/docs/ai/SUPERPOWERS_BRIDGE.md`: map Superpowers plan output to locked plan.
- `profiles/agent-adapters/docs/ai/CODEX_BRIDGE.md`: require locked plan before implementation.
- `profiles/agent-adapters/docs/ai/CLAUDE_CODE_BRIDGE.md`: require locked plan before implementation.
- `scripts/test-kit.sh`: add positive install checks and negative drift scenarios.

---

### Task 1: Add Failing Kit Tests For Plan Engine

**Files:**
- Modify: `scripts/test-kit.sh`

- [ ] **Step 1: Write failing install assertions**

Add these assertions after the existing `assert_file "$MVP_TARGET/docs/tasks/T-000.md"` block:

```bash
assert_file "$MVP_TARGET/docs/CONSTITUTION.md"
assert_file "$MVP_TARGET/docs/specs/REQUIREMENTS_TEMPLATE.md"
assert_file "$MVP_TARGET/docs/designs/DESIGN_TEMPLATE.md"
assert_file "$MVP_TARGET/docs/plans/PLAN_TEMPLATE.md"
assert_file "$MVP_TARGET/docs/plans/T-000-plan.md"
assert_contains "$(cat "$MVP_TARGET/docs/AI_STATE.yml")" "require_plan_guard: true"
assert_contains "$(cat "$MVP_TARGET/docs/AI_STATE.yml")" "plan_status: locked"
```

Add these executable assertions after the existing script assertions:

```bash
assert_executable "$MVP_TARGET/scripts/spec-lint.sh"
assert_executable "$MVP_TARGET/scripts/plan-lock.sh"
assert_executable "$MVP_TARGET/scripts/plan-guard.sh"
assert_executable "$MVP_TARGET/scripts/plan-step.sh"
```

- [ ] **Step 2: Write failing positive plan-flow assertions**

Add these checks after `mvp_drift` assertions:

```bash
mvp_spec_lint="$(cd "$MVP_TARGET" && bash scripts/spec-lint.sh T-000)"
assert_contains "$mvp_spec_lint" "SPEC_LINT_PASS"

mvp_plan_guard="$(cd "$MVP_TARGET" && bash scripts/plan-guard.sh T-000 S-001)"
assert_contains "$mvp_plan_guard" "PLAN_GUARD_PASS"

mvp_plan_start="$(cd "$MVP_TARGET" && bash scripts/plan-step.sh T-000 S-001 --start)"
assert_contains "$mvp_plan_start" "PLAN_STEP_START"

mvp_plan_complete="$(cd "$MVP_TARGET" && bash scripts/plan-step.sh T-000 S-001 --complete)"
assert_contains "$mvp_plan_complete" "PLAN_STEP_COMPLETE"
```

- [ ] **Step 3: Write failing negative drift assertions**

Add these checks after the positive plan-flow assertions:

```bash
cp "$MVP_TARGET/docs/AI_STATE.yml" "$MVP_TARGET/docs/AI_STATE.yml.bak"
sed -i 's/plan_status: locked/plan_status: draft/' "$MVP_TARGET/docs/AI_STATE.yml"
if (cd "$MVP_TARGET" && bash scripts/plan-guard.sh T-000 S-001) >/tmp/vibecoding-kit-plan-unlocked.out 2>&1; then
  fail "plan-guard should reject unlocked plan"
fi
assert_contains "$(cat /tmp/vibecoding-kit-plan-unlocked.out)" "PLAN_GUARD_FAIL: plan not locked"
mv "$MVP_TARGET/docs/AI_STATE.yml.bak" "$MVP_TARGET/docs/AI_STATE.yml"

if (cd "$MVP_TARGET" && bash scripts/plan-guard.sh T-000 S-999) >/tmp/vibecoding-kit-plan-step.out 2>&1; then
  fail "plan-guard should reject wrong current step"
fi
assert_contains "$(cat /tmp/vibecoding-kit-plan-step.out)" "PLAN_STEP_FAIL: step is not current"

printf 'drift\n' >"$MVP_TARGET/unplanned.txt"
if (cd "$MVP_TARGET" && bash scripts/plan-guard.sh T-000 S-001) >/tmp/vibecoding-kit-plan-drift.out 2>&1; then
  fail "plan-guard should reject files outside current step allowlist"
fi
assert_contains "$(cat /tmp/vibecoding-kit-plan-drift.out)" "PLAN_GUARD_FAIL: unauthorized file"
rm -f "$MVP_TARGET/unplanned.txt"

cp "$MVP_TARGET/docs/plans/T-000-plan.md" "$MVP_TARGET/docs/plans/T-000-plan.md.bak"
printf '\nallowed_changes:\n- **\n' >>"$MVP_TARGET/docs/plans/T-000-plan.md"
if (cd "$MVP_TARGET" && bash scripts/plan-guard.sh T-000 S-001) >/tmp/vibecoding-kit-plan-hash.out 2>&1; then
  fail "plan-guard should reject locked plan changes"
fi
assert_contains "$(cat /tmp/vibecoding-kit-plan-hash.out)" "PLAN_GUARD_FAIL: locked plan changed"
mv "$MVP_TARGET/docs/plans/T-000-plan.md.bak" "$MVP_TARGET/docs/plans/T-000-plan.md"
```

- [ ] **Step 4: Run test to verify red**

Run:

```bash
bash scripts/test-kit.sh
```

Expected: exits non-zero with missing plan-engine files or scripts, because implementation has not been added.

- [ ] **Step 5: Commit red test**

```bash
git add scripts/test-kit.sh
git commit -m "test: cover plan engine workflow"
```

---

### Task 2: Add Plan-Engine Templates And State Defaults

**Files:**
- Create: `core/docs/CONSTITUTION.md`
- Create: `core/docs/specs/REQUIREMENTS_TEMPLATE.md`
- Create: `core/docs/designs/DESIGN_TEMPLATE.md`
- Create: `core/docs/plans/PLAN_TEMPLATE.md`
- Create: `core/docs/plans/T-000-plan.md`
- Modify: `core/docs/AI_STATE.yml`
- Modify: `core/docs/AI_RULES_INDEX.md`
- Modify: `core/docs/TASK_TEMPLATE.md`
- Modify: `core/docs/tasks/T-000.md`

- [ ] **Step 1: Create `core/docs/CONSTITUTION.md`**

```md
# Project Constitution

These rules apply across every task.

## Principles

- Plan before implementation.
- Keep requirements, design, plan, and task files synchronized.
- Only change files allowed by the locked plan step.
- Do not bypass security, permissions, audit, validation, or state transitions.
- Report commit and push checkpoints during closeout.

## Enforcement

Run:

```bash
bash scripts/spec-lint.sh T-xxx
bash scripts/plan-guard.sh T-xxx S-xxx
bash scripts/drift-guard.sh
bash scripts/task-closeout.sh T-xxx --write-report
```
```

- [ ] **Step 2: Create `core/docs/specs/REQUIREMENTS_TEMPLATE.md`**

```md
# T-xxx Requirements

status: draft

## Problem

Describe the user-visible problem.

## Goals

- item

## Non-Goals

- item

## Acceptance Criteria

- item

## Risk

low
```

- [ ] **Step 3: Create `core/docs/designs/DESIGN_TEMPLATE.md`**

```md
# T-xxx Design

status: draft

## Architecture

Describe the selected architecture.

## Files

- path: reason

## Data Flow

- step

## Error Handling

- case: response

## Testing

- command
```

- [ ] **Step 4: Create `core/docs/plans/PLAN_TEMPLATE.md`**

```md
# T-xxx Plan

status: draft

## S-001 Step Name

status: pending

allowed_changes:
- path/**

forbidden_changes:
- .env*
- target/**
- node_modules/**

commands:
- bash scripts/drift-guard.sh

expected:
- DRIFT_GUARD_PASS

commit:
- required
```

- [ ] **Step 5: Create `core/docs/plans/T-000-plan.md`**

```md
# T-000 Initialize Vibecoding OS Plan

status: locked

## S-001 Verify Initialized Kit

status: pending

allowed_changes:
- **

forbidden_changes:
- .env*
- target/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- bash scripts/spec-lint.sh T-000
- bash scripts/plan-guard.sh T-000 S-001
- bash scripts/drift-guard.sh
- bash scripts/task-closeout.sh T-000 --no-tests --write-report

expected:
- SPEC_LINT_PASS
- PLAN_GUARD_PASS
- DRIFT_GUARD_PASS
- CLOSEOUT

commit:
- required
```

- [ ] **Step 6: Modify `core/docs/AI_STATE.yml`**

Add these fields after `mode: initialization`:

```yml
workflow_status: implementation
requirements_status: approved
design_status: approved
plan_status: locked
current_step: S-001
require_plan_guard: true
require_step_commit: true
plan_change_status: none
plan_hash: __PLAN_HASH__
```

- [ ] **Step 7: Modify `core/docs/AI_RULES_INDEX.md`**

Add this section after `## Required Startup`:

```md
## Plan Engine

When `require_plan_guard: true`, implementation requires:

```bash
bash scripts/spec-lint.sh T-xxx
bash scripts/plan-guard.sh T-xxx S-xxx
```

Plan changes require:

```txt
PLAN_CHANGE_REQUIRED
reason:
requested_change:
affected_files:
suggested_plan_update:
```
```

- [ ] **Step 8: Modify `core/docs/TASK_TEMPLATE.md`**

Add this section before `## Required Work`:

```md
## Plan Contract

- requirements: `docs/specs/T-xxx-requirements.md`
- design: `docs/designs/T-xxx-design.md`
- plan: `docs/plans/T-xxx-plan.md`
- current_step: S-001
```

- [ ] **Step 9: Modify `core/docs/tasks/T-000.md`**

Add this section before `## Required Work`:

```md
## Plan Contract

- requirements: not required for initialization
- design: not required for initialization
- plan: `docs/plans/T-000-plan.md`
- current_step: S-001
```

- [ ] **Step 10: Run test to verify remaining red**

Run:

```bash
bash scripts/test-kit.sh
```

Expected: exits non-zero because `spec-lint.sh`, `plan-lock.sh`, `plan-guard.sh`, and `plan-step.sh` are not implemented yet.

- [ ] **Step 11: Commit templates**

```bash
git add core/docs
git commit -m "feat: add plan engine templates"
```

---

### Task 3: Add Shared Plan Library

**Files:**
- Create: `core/scripts/plan-lib.sh`

- [ ] **Step 1: Create `core/scripts/plan-lib.sh`**

```bash
#!/usr/bin/env bash

plan_task_file() {
  local task="$1"
  printf 'docs/tasks/%s.md\n' "$task"
}

plan_file() {
  local task="$1"
  printf 'docs/plans/%s-plan.md\n' "$task"
}

state_get() {
  local key="$1"
  awk -F: -v key="$key" '$1 == key { v=$2; gsub(/^[ \t]+|[ \t]+$/, "", v); print v; exit }' docs/AI_STATE.yml 2>/dev/null || true
}

state_set() {
  local key="$1"
  local value="$2"
  local tmp
  tmp="$(mktemp)"
  awk -v key="$key" -v value="$value" '
    BEGIN { done = 0 }
    $0 ~ "^" key ":" { print key ": " value; done = 1; next }
    { print }
    END { if (done == 0) print key ": " value }
  ' docs/AI_STATE.yml >"$tmp"
  mv "$tmp" docs/AI_STATE.yml
}

plan_hash() {
  local file="$1"
  awk '!/^status:[[:space:]]/ { print }' "$file" | sha256sum | awk '{ print $1 }'
}

changed_files() {
  {
    git diff --name-only HEAD 2>/dev/null || git diff --name-only
    git ls-files --others --exclude-standard
  } | sed '/^$/d' | sort -u
}

step_block() {
  local file="$1"
  local step="$2"
  awk -v step="$step" '
    $0 ~ "^## " step " " { in_step = 1; print; next }
    in_step && /^## S-[0-9][0-9][0-9] / { exit }
    in_step { print }
  ' "$file"
}

step_field() {
  local file="$1"
  local step="$2"
  local field="$3"
  step_block "$file" "$step" | awk -v field="$field" '
    $0 == field ":" { in_field = 1; next }
    in_field && /^[a-z_]+:/ { exit }
    in_field && /^- / { line=$0; sub(/^- /, "", line); print line }
  '
}

step_status() {
  local file="$1"
  local step="$2"
  step_block "$file" "$step" | awk -F: '$1 == "status" { v=$2; gsub(/^[ \t]+|[ \t]+$/, "", v); print v; exit }'
}

path_matches_pattern() {
  local file="$1"
  local pattern="$2"
  [[ -n "$pattern" ]] || return 1
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
  local plan="$1"
  local step="$2"
  local file="$3"
  local pattern
  while IFS= read -r pattern; do
    path_matches_pattern "$file" "$pattern" && return 0
  done < <(step_field "$plan" "$step" "allowed_changes")
  return 1
}

file_forbidden_by_step() {
  local plan="$1"
  local step="$2"
  local file="$3"
  local pattern
  while IFS= read -r pattern; do
    path_matches_pattern "$file" "$pattern" && return 0
  done < <(step_field "$plan" "$step" "forbidden_changes")
  return 1
}

first_step() {
  local file="$1"
  awk '/^## S-[0-9][0-9][0-9] / { print $2; exit }' "$file"
}

next_step_after() {
  local file="$1"
  local current="$2"
  awk -v current="$current" '
    /^## S-[0-9][0-9][0-9] / {
      if (seen == 1) { print $2; exit }
      if ($2 == current) seen = 1
    }
  ' "$file"
}
```

- [ ] **Step 2: Make library executable-compatible**

Run:

```bash
chmod +x core/scripts/plan-lib.sh
```

Expected: command exits 0.

- [ ] **Step 3: Commit library**

```bash
git add core/scripts/plan-lib.sh
git commit -m "feat: add plan engine shell library"
```

---

### Task 4: Implement Spec Lint And Plan Lock

**Files:**
- Create: `core/scripts/spec-lint.sh`
- Create: `core/scripts/plan-lock.sh`

- [ ] **Step 1: Create `core/scripts/spec-lint.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

task="${1:-}"
[[ "$task" =~ ^T-[0-9]{3}$ ]] || {
  echo "SPEC_LINT_FAIL: missing or invalid task id" >&2
  exit 2
}

task_file="docs/tasks/${task}.md"
plan_file="docs/plans/${task}-plan.md"

[[ -f "$task_file" ]] || {
  echo "SPEC_LINT_FAIL: missing $task_file" >&2
  exit 1
}

[[ -f "$plan_file" ]] || {
  echo "SPEC_LINT_FAIL: missing $plan_file" >&2
  exit 1
}

if [[ "$task" != "T-000" ]]; then
  [[ -f "docs/specs/${task}-requirements.md" ]] || {
    echo "SPEC_LINT_FAIL: missing docs/specs/${task}-requirements.md" >&2
    exit 1
  }
  [[ -f "docs/designs/${task}-design.md" ]] || {
    echo "SPEC_LINT_FAIL: missing docs/designs/${task}-design.md" >&2
    exit 1
  }
fi

for section in "## Goal" "## Background" "## Plan Contract" "## Allowed Changes" "## Forbidden Changes" "## Required Work" "## Forbidden Actions" "## Test Requirements" "## Completion Criteria" "## Risk"; do
  if ! rg -q "^${section}$" "$task_file"; then
    echo "SPEC_LINT_FAIL: $task_file missing $section" >&2
    exit 1
  fi
done

if ! rg -q '^## S-[0-9]{3} ' "$plan_file"; then
  echo "SPEC_LINT_FAIL: $plan_file missing plan steps" >&2
  exit 1
fi

while IFS= read -r step; do
  block="$(awk -v step="$step" '$0 ~ "^## " step " " { in_step = 1; print; next } in_step && /^## S-[0-9][0-9][0-9] / { exit } in_step { print }' "$plan_file")"
  for field in status allowed_changes forbidden_changes commands expected commit; do
    if ! printf '%s\n' "$block" | rg -q "^${field}:"; then
      echo "SPEC_LINT_FAIL: $plan_file $step missing $field" >&2
      exit 1
    fi
  done
done < <(awk '/^## S-[0-9][0-9][0-9] / { print $2 }' "$plan_file")

echo "SPEC_LINT_PASS"
```

- [ ] **Step 2: Create `core/scripts/plan-lock.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
. scripts/plan-lib.sh

task="${1:-}"
[[ "$task" =~ ^T-[0-9]{3}$ ]] || {
  echo "PLAN_LOCK_FAIL: missing or invalid task id" >&2
  exit 2
}

plan="$(plan_file "$task")"
[[ -f "$plan" ]] || {
  echo "PLAN_LOCK_FAIL: missing $plan" >&2
  exit 1
}

bash scripts/spec-lint.sh "$task" >/tmp/vibecoding-kit-spec-lint.out

requirements_status="$(state_get requirements_status)"
design_status="$(state_get design_status)"

if [[ "$task" != "T-000" && "$requirements_status" != "approved" ]]; then
  echo "PLAN_LOCK_FAIL: requirements not approved" >&2
  exit 1
fi

if [[ "$task" != "T-000" && "$design_status" != "approved" ]]; then
  echo "PLAN_LOCK_FAIL: design not approved" >&2
  exit 1
fi

step="$(first_step "$plan")"
[[ "$step" =~ ^S-[0-9]{3}$ ]] || {
  echo "PLAN_LOCK_FAIL: missing first step" >&2
  exit 1
}

state_set current_task "$task"
state_set plan_status locked
state_set workflow_status implementation
state_set current_step "$step"
state_set require_plan_guard true
state_set plan_change_status none
state_set plan_hash "$(plan_hash "$plan")"

echo "PLAN_LOCK_PASS"
echo "current_task: $task"
echo "current_step: $step"
```

- [ ] **Step 3: Make scripts executable**

Run:

```bash
chmod +x core/scripts/spec-lint.sh core/scripts/plan-lock.sh
```

Expected: command exits 0.

- [ ] **Step 4: Run test to verify partial green**

Run:

```bash
bash scripts/test-kit.sh
```

Expected: exits non-zero because `plan-guard.sh` and `plan-step.sh` are still missing.

- [ ] **Step 5: Commit lint and lock scripts**

```bash
git add core/scripts/spec-lint.sh core/scripts/plan-lock.sh
git commit -m "feat: add spec lint and plan lock"
```

---

### Task 5: Implement Plan Guard And Plan Step

**Files:**
- Create: `core/scripts/plan-guard.sh`
- Create: `core/scripts/plan-step.sh`

- [ ] **Step 1: Create `core/scripts/plan-guard.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
. scripts/plan-lib.sh

task="${1:-}"
step="${2:-}"

[[ "$task" =~ ^T-[0-9]{3}$ ]] || {
  echo "PLAN_GUARD_FAIL: missing or invalid task id" >&2
  exit 2
}

[[ "$step" =~ ^S-[0-9]{3}$ ]] || {
  echo "PLAN_GUARD_FAIL: missing or invalid step id" >&2
  exit 2
}

plan="$(plan_file "$task")"
[[ -f "$plan" ]] || {
  echo "PLAN_GUARD_FAIL: missing plan" >&2
  exit 1
}

require_plan_guard="$(state_get require_plan_guard)"
if [[ "$require_plan_guard" != "true" ]]; then
  echo "PLAN_GUARD_SKIP: require_plan_guard is not true"
  exit 0
fi

plan_status="$(state_get plan_status)"
if [[ "$plan_status" != "locked" ]]; then
  echo "PLAN_GUARD_FAIL: plan not locked" >&2
  exit 1
fi

current_task="$(state_get current_task)"
if [[ "$current_task" != "$task" ]]; then
  echo "PLAN_GUARD_FAIL: task is not current" >&2
  exit 1
fi

current_step="$(state_get current_step)"
if [[ "$current_step" != "$step" ]]; then
  echo "PLAN_STEP_FAIL: step is not current" >&2
  exit 1
fi

expected_hash="$(state_get plan_hash)"
actual_hash="$(plan_hash "$plan")"
if [[ -n "$expected_hash" && "$expected_hash" != "__PLAN_HASH__" && "$expected_hash" != "$actual_hash" ]]; then
  echo "PLAN_GUARD_FAIL: locked plan changed" >&2
  exit 1
fi

unauthorized=""
while IFS= read -r file; do
  [[ -n "$file" ]] || continue
  [[ "$file" == "docs/AI_STATE.yml" ]] && continue
  if file_forbidden_by_step "$plan" "$step" "$file"; then
    unauthorized+="$file"$'\n'
    continue
  fi
  if ! file_allowed_by_step "$plan" "$step" "$file"; then
    unauthorized+="$file"$'\n'
  fi
done < <(changed_files)

if [[ -n "$unauthorized" ]]; then
  echo "PLAN_GUARD_FAIL: unauthorized file" >&2
  printf '%s' "$unauthorized" >&2
  exit 1
fi

echo "PLAN_GUARD_PASS"
echo "current_task: $task"
echo "current_step: $step"
```

- [ ] **Step 2: Create `core/scripts/plan-step.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
. scripts/plan-lib.sh

task="${1:-}"
step="${2:-}"
action="${3:-}"

[[ "$task" =~ ^T-[0-9]{3}$ ]] || {
  echo "PLAN_STEP_FAIL: missing or invalid task id" >&2
  exit 2
}

[[ "$step" =~ ^S-[0-9]{3}$ ]] || {
  echo "PLAN_STEP_FAIL: missing or invalid step id" >&2
  exit 2
}

case "$action" in
  --start|--complete|--block) ;;
  *) echo "PLAN_STEP_FAIL: invalid action" >&2; exit 2 ;;
esac

plan="$(plan_file "$task")"
[[ -f "$plan" ]] || {
  echo "PLAN_STEP_FAIL: missing plan" >&2
  exit 1
}

current_task="$(state_get current_task)"
current_step="$(state_get current_step)"
plan_status="$(state_get plan_status)"

[[ "$current_task" == "$task" ]] || {
  echo "PLAN_STEP_FAIL: task is not current" >&2
  exit 1
}

[[ "$current_step" == "$step" ]] || {
  echo "PLAN_STEP_FAIL: step is not current" >&2
  exit 1
}

[[ "$plan_status" == "locked" ]] || {
  echo "PLAN_STEP_FAIL: plan not locked" >&2
  exit 1
}

case "$action" in
  --start)
    state_set workflow_status implementation
    echo "PLAN_STEP_START"
    echo "current_task: $task"
    echo "current_step: $step"
    ;;
  --complete)
    bash scripts/plan-guard.sh "$task" "$step" >/tmp/vibecoding-kit-plan-guard.out
    next="$(next_step_after "$plan" "$step")"
    if [[ -n "$next" ]]; then
      state_set current_step "$next"
      state_set workflow_status implementation
    else
      state_set workflow_status closeout
    fi
    echo "PLAN_STEP_COMPLETE"
    echo "completed_step: $step"
    echo "next_step: ${next:-none}"
    ;;
  --block)
    state_set workflow_status blocked
    state_set plan_change_status requested
    echo "PLAN_STEP_BLOCKED"
    echo "current_task: $task"
    echo "current_step: $step"
    ;;
esac
```

- [ ] **Step 3: Make scripts executable**

Run:

```bash
chmod +x core/scripts/plan-guard.sh core/scripts/plan-step.sh
```

Expected: command exits 0.

- [ ] **Step 4: Run test to verify guard behavior**

Run:

```bash
bash scripts/test-kit.sh
```

Expected: may still fail because `drift-guard.sh`, `task-closeout.sh`, and `test-ai-guards.sh` do not yet know about plan-engine scripts.

- [ ] **Step 5: Commit guard and step scripts**

```bash
git add core/scripts/plan-guard.sh core/scripts/plan-step.sh
git commit -m "feat: add plan guard and step control"
```

---

### Task 6: Integrate Plan Engine Into Guards And Closeout

**Files:**
- Modify: `core/scripts/drift-guard.sh`
- Modify: `core/scripts/task-closeout.sh`
- Modify: `core/scripts/test-ai-guards.sh`

- [ ] **Step 1: Modify `core/scripts/drift-guard.sh`**

Add this block after `current_task` is computed and before `bash scripts/secrets-guard.sh`:

```bash
require_plan_guard="$(awk -F: '$1 == "require_plan_guard" { v=$2; gsub(/^[ \t]+|[ \t]+$/, "", v); print v; exit }' docs/AI_STATE.yml 2>/dev/null || true)"
current_step="$(awk -F: '$1 == "current_step" { v=$2; gsub(/^[ \t]+|[ \t]+$/, "", v); print v; exit }' docs/AI_STATE.yml 2>/dev/null || true)"
if [[ "$require_plan_guard" == "true" && "$current_task" =~ ^T-[0-9]{3}$ && "$current_step" =~ ^S-[0-9]{3}$ ]]; then
  bash scripts/plan-guard.sh "$current_task" "$current_step"
fi
```

- [ ] **Step 2: Modify `core/scripts/task-closeout.sh`**

Add these variables after `drift_result="DRIFT_GUARD_PASS"`:

```bash
plan_result="not_required"
require_plan_guard="$(awk -F: '$1 == "require_plan_guard" { v=$2; gsub(/^[ \t]+|[ \t]+$/, "", v); print v; exit }' docs/AI_STATE.yml 2>/dev/null || true)"
current_step="$(awk -F: '$1 == "current_step" { v=$2; gsub(/^[ \t]+|[ \t]+$/, "", v); print v; exit }' docs/AI_STATE.yml 2>/dev/null || true)"
if [[ "$require_plan_guard" == "true" ]]; then
  if [[ "$current_step" =~ ^S-[0-9]{3}$ ]]; then
    bash scripts/plan-guard.sh "$task" "$current_step" >/tmp/vibecoding-kit-plan-guard.out
    plan_result="PLAN_GUARD_PASS $current_step"
  else
    plan_result="PLAN_GUARD_FAIL missing_current_step"
  fi
fi
```

Add to the report validation section:

```md
- plan_guard: $plan_result
```

Add to stdout after `drift_guard: $drift_result`:

```bash
plan_guard: $plan_result
```

Add this final assertion before the `tests_result` assertion:

```bash
[[ "$plan_result" != PLAN_GUARD_FAIL* ]] || exit 1
```

- [ ] **Step 3: Modify `core/scripts/test-ai-guards.sh`**

Extend required executable list:

```bash
for file in scripts/ai-preflight.sh scripts/drift-guard.sh scripts/task-closeout.sh scripts/install-git-hooks.sh scripts/task-card-lint.sh scripts/secrets-guard.sh scripts/spec-lint.sh scripts/plan-lock.sh scripts/plan-guard.sh scripts/plan-step.sh; do
  [[ -x "$file" ]] || fail "$file missing or not executable"
done
```

Add assertions after `task_lint`:

```bash
spec_lint="$(bash scripts/spec-lint.sh T-000)"
assert_contains "$spec_lint" "SPEC_LINT_PASS"

plan_guard="$(bash scripts/plan-guard.sh T-000 S-001)"
assert_contains "$plan_guard" "PLAN_GUARD_PASS"
```

Add closeout assertion:

```bash
assert_contains "$closeout" "plan_guard:"
```

- [ ] **Step 4: Run full tests**

Run:

```bash
bash scripts/test-kit.sh
```

Expected: `KIT_TESTS_PASS`.

- [ ] **Step 5: Commit integration**

```bash
git add core/scripts/drift-guard.sh core/scripts/task-closeout.sh core/scripts/test-ai-guards.sh
git commit -m "feat: enforce plan engine in guards"
```

---

### Task 7: Update Agent Adapter Documentation

**Files:**
- Modify: `profiles/agent-adapters/docs/ai/PLAN_PROTOCOL.md`
- Modify: `profiles/agent-adapters/docs/ai/SUPERPOWERS_BRIDGE.md`
- Modify: `profiles/agent-adapters/docs/ai/CODEX_BRIDGE.md`
- Modify: `profiles/agent-adapters/docs/ai/CLAUDE_CODE_BRIDGE.md`

- [ ] **Step 1: Update `PLAN_PROTOCOL.md`**

Add this section after `## Planning Rules`:

```md
## Plan Engine

When `require_plan_guard: true`, native planning output must be converted into:

- `docs/specs/T-xxx-requirements.md`
- `docs/designs/T-xxx-design.md`
- `docs/plans/T-xxx-plan.md`
- `docs/tasks/T-xxx.md`

Implementation may begin only after:

```bash
bash scripts/spec-lint.sh T-xxx
bash scripts/plan-lock.sh T-xxx
bash scripts/plan-guard.sh T-xxx S-xxx
```

If a tool needs to change scope after lock, it must stop and report
`PLAN_CHANGE_REQUIRED`.
```

- [ ] **Step 2: Update bridge docs**

Add this paragraph to each bridge file:

```md
Before implementation, convert the tool's native plan into the locked plan
engine contract. Native todos, modes, and plan panes are scratch state; the
portable contract is `docs/plans/T-xxx-plan.md` plus `docs/AI_STATE.yml`.
```

- [ ] **Step 3: Run tests**

Run:

```bash
bash scripts/test-kit.sh
```

Expected: `KIT_TESTS_PASS`.

- [ ] **Step 4: Commit adapter docs**

```bash
git add profiles/agent-adapters/docs/ai
git commit -m "docs: align adapters with plan engine"
```

---

### Task 8: Final Verification And Closeout

**Files:**
- Verify all changed files.

- [ ] **Step 1: Run full kit tests**

Run:

```bash
bash scripts/test-kit.sh
```

Expected: output ends with:

```txt
KIT_TESTS_PASS
```

- [ ] **Step 2: Run whitespace check**

Run:

```bash
git diff --check
```

Expected: no output and exit 0.

- [ ] **Step 3: Inspect git status**

Run:

```bash
git status --short
```

Expected: no uncommitted changes after all task commits.

- [ ] **Step 4: Report commit history**

Run:

```bash
git log --oneline -8
```

Expected: shows the plan-engine task commits after `f5e6f17 docs: add plan engine design`.

---

## Self-Review

Spec coverage:

- Spec/design/plan/task files are covered by Task 2.
- `AI_STATE.yml` workflow fields are covered by Task 2.
- `spec-lint.sh`, `plan-lock.sh`, `plan-guard.sh`, and `plan-step.sh` are covered by Tasks 4 and 5.
- Drift and closeout integration are covered by Task 6.
- Agent adapter updates are covered by Task 7.
- Positive and negative tests are covered by Task 1 and Task 8.

Placeholder scan:

- The plan uses `T-xxx` and `S-xxx` only as protocol identifiers.
- No deferred implementation sections are left unspecified.

Type and name consistency:

- State fields match the design: `workflow_status`, `requirements_status`, `design_status`, `plan_status`, `current_step`, `require_plan_guard`, `require_step_commit`, `plan_change_status`, and `plan_hash`.
- Script names match the design: `spec-lint.sh`, `plan-lock.sh`, `plan-guard.sh`, and `plan-step.sh`.
