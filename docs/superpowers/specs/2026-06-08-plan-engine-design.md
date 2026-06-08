# Plan Engine Design

date: 2026-06-08
status: draft-for-review
source: `docs/research/AI_WORKFLOW_BENCHMARK.md`

## Goal

Turn vibecoding-kit from a rule-and-closeout template into a lightweight
workflow engine that makes AI plan drift detectable, blockable, and auditable
across Codex, Claude Code, Superpowers, Cursor, Copilot, Cline, Roo, Windsurf,
Gemini, and other agent tools.

This design does not promise that AI will never make mistakes. It promises a
machine-checkable protocol where implementation cannot be claimed complete when
the plan is unlocked, the current step is wrong, changed files exceed the step
allowlist, required checks fail, or checkpoints are missing.

## Non-Goals

- Do not build a full project-management system.
- Do not depend on one vendor's native todo or planning state.
- Do not make tool-specific adapters the source of truth.
- Do not require a heavy parser or non-shell runtime for MVP.
- Do not block small low-risk tasks with excessive ceremony beyond the minimum
  plan lock and guard checks.

## Architecture

The plan engine has four layers:

| Layer | Responsibility | Files |
| --- | --- | --- |
| Intent | State what must be built and why | `docs/specs/T-xxx-requirements.md` |
| Design | Define architecture, boundaries, data flow, and risk | `docs/designs/T-xxx-design.md` |
| Execution Plan | Freeze ordered steps and per-step constraints | `docs/plans/T-xxx-plan.md` |
| Enforcement | Check state, step, changed files, guards, and checkpoints | `docs/AI_STATE.yml`, `scripts/*.sh` |

Agent-specific files such as `AGENTS.md`, `CLAUDE.md`, `.cursor/rules/*.mdc`,
and `.github/copilot-instructions.md` remain thin entry points. They must point
agents to the same plan protocol instead of duplicating full rules.

## Lifecycle

```txt
planning
  -> requirements approved
  -> design approved
  -> plan draft
  -> plan locked
  -> implementation step loop
  -> closeout
  -> complete
```

Implementation is only allowed when:

- `requirements_status: approved`
- `design_status: approved` for medium/high-risk tasks
- `plan_status: locked`
- `current_step` matches the step being executed
- current changed files are within the current step allowlist

If an agent needs to change the plan, it must stop and report:

```txt
PLAN_CHANGE_REQUIRED
reason:
requested_change:
affected_files:
suggested_plan_update:
```

## State Model

`docs/AI_STATE.yml` becomes the workflow state source:

```yml
current_task: T-001
workflow_status: implementation
requirements_status: approved
design_status: approved
plan_status: locked
current_step: S-003
allowed_next_steps:
  - S-003
require_plan_guard: true
require_step_commit: true
plan_change_status: none
```

Allowed values:

| Field | Values |
| --- | --- |
| `workflow_status` | `planning`, `implementation`, `blocked`, `closeout`, `complete` |
| `requirements_status` | `draft`, `approved`, `change_required` |
| `design_status` | `draft`, `approved`, `change_required` |
| `plan_status` | `draft`, `locked`, `change_required` |
| `plan_change_status` | `none`, `requested`, `approved`, `rejected` |

The scripts should tolerate legacy projects that do not have plan-engine fields
yet. Once `require_plan_guard: true` is set, the stricter checks apply.

## File Layout

The core template should add:

```txt
docs/CONSTITUTION.md
docs/specs/REQUIREMENTS_TEMPLATE.md
docs/designs/DESIGN_TEMPLATE.md
docs/plans/PLAN_TEMPLATE.md
docs/plans/T-000-plan.md
```

Generated projects then create task-specific files:

```txt
docs/specs/T-xxx-requirements.md
docs/designs/T-xxx-design.md
docs/plans/T-xxx-plan.md
docs/tasks/T-xxx.md
```

`docs/tasks/T-xxx.md` remains the compact current-task card. The plan file owns
step order and per-step constraints.

## Plan File Contract

Each step in `docs/plans/T-xxx-plan.md` must be self-contained:

```md
## S-003 Implement API Contract Guard

status: pending

allowed_changes:
- scripts/api-contract-guard.sh
- docs/API_SPEC.md

forbidden_changes:
- auth/**
- database/**
- .env*

commands:
- bash scripts/api-contract-guard.sh T-xxx
- bash scripts/drift-guard.sh

expected:
- API_CONTRACT_LINT_PASS
- DRIFT_GUARD_PASS

commit:
- required
```

Required per-step fields:

| Field | Purpose |
| --- | --- |
| `status` | `pending`, `in_progress`, `completed`, or `blocked` |
| `allowed_changes` | Path allowlist checked against actual git changes |
| `forbidden_changes` | Explicit denylist for high-risk paths |
| `commands` | Verification commands for this step |
| `expected` | Output or state that proves the step passed |
| `commit` | Whether the step needs a checkpoint commit |

## Script Responsibilities

| Script | Responsibility | Blocking examples |
| --- | --- | --- |
| `scripts/spec-lint.sh T-xxx` | Validate requirements/design/plan/task structure | Missing required sections, unsupported statuses |
| `scripts/plan-lock.sh T-xxx` | Lock a complete plan after approval | Missing specs, unapproved design, incomplete steps |
| `scripts/plan-guard.sh T-xxx S-xxx` | Verify state and changed files before/after work | Wrong step, unlocked plan, unauthorized files |
| `scripts/plan-step.sh T-xxx S-xxx --start|--complete|--block` | Move step state forward | Step skipped, required checks missing |
| `scripts/task-closeout.sh` | Final enforcement and reporting | Plan drift, failed guards, missing checkpoint |

`scripts/drift-guard.sh` should run `plan-guard.sh` automatically when
`require_plan_guard: true`.

## Data Flow

1. Agent generates or updates requirements/design/plan files.
2. User approves the artifacts or the task is explicitly low-risk.
3. `plan-lock.sh` validates structure and updates `AI_STATE.yml`.
4. Agent starts the current step with `plan-step.sh --start`.
5. Agent edits only paths allowed by the current step.
6. `plan-guard.sh` compares git changes against the step contract.
7. Step commands run and their results are recorded through closeout.
8. `plan-step.sh --complete` advances `current_step`.
9. `task-closeout.sh` writes the report and checkpoint state.

## Error Handling

| Failure | Required response |
| --- | --- |
| Plan missing | `PLAN_GUARD_FAIL: missing plan` |
| Plan not locked | `PLAN_GUARD_FAIL: plan not locked` |
| Wrong step | `PLAN_STEP_FAIL: step is not current` |
| Unauthorized file | `PLAN_GUARD_FAIL: unauthorized file` |
| Locked plan edited | `PLAN_GUARD_FAIL: locked plan changed` |
| Step needs new scope | `PLAN_CHANGE_REQUIRED` block |
| Required command fails | `task-closeout.sh` exits non-zero |
| No commit | Closeout reports `NO_COMMIT_CHECKPOINT` |

Plan changes must be explicit. The system should not silently mutate a locked
plan to fit the agent's edits.

## Testing Strategy

The kit test suite should add red-team scenarios:

| Scenario | Expected result |
| --- | --- |
| Generated project has plan-engine files | Files exist after init |
| Unlocked plan plus implementation | `PLAN_GUARD_FAIL: plan not locked` |
| Wrong current step | `PLAN_STEP_FAIL: step is not current` |
| Plan outside allowlist | `PLAN_GUARD_FAIL: unauthorized file` |
| Locked plan changed | `PLAN_GUARD_FAIL: locked plan changed` |
| `plan-step --complete` skips a step | Non-zero exit |
| Closeout without plan guard | Non-zero exit when `require_plan_guard: true` |

Existing tests in `scripts/test-kit.sh` remain the outer acceptance suite.

## Rollout

MVP:

1. Add templates and default `AI_STATE.yml` fields.
2. Implement `spec-lint.sh`, `plan-lock.sh`, `plan-guard.sh`, and `plan-step.sh`.
3. Integrate plan guard into `drift-guard.sh` and `task-closeout.sh`.
4. Update `agent-adapters` docs so every tool points to plan-engine protocol.
5. Add regression tests for drift scenarios.

Follow-up:

1. Add richer plan parsing if shell parsing becomes fragile.
2. Add mode-specific adapter refinements for Claude Code, Cline, Roo, and
   Windsurf.
3. Add optional CI reports that summarize current plan progress.

## Acceptance Criteria

- A generated full project includes spec/design/plan templates.
- A locked plan is required before implementation when `require_plan_guard: true`.
- Current step mismatch is blocked.
- Changed files outside the current step allowlist are blocked.
- Locked plan changes are blocked unless `plan_change_status` allows them.
- `task-closeout.sh` reports plan status, current step, guard result, commit
  checkpoint, and push checkpoint.
- `bash scripts/test-kit.sh` covers positive install flow and negative drift
  cases.
