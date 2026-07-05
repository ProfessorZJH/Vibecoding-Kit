# Plan Lock Workflow

## Purpose

Validate and lock the current task plan before implementation begins.

## Inputs

- `docs/tasks/T-xxx.md`
- `docs/specs/T-xxx-requirements.md`
- `docs/designs/T-xxx-design.md`
- `docs/plans/T-xxx-plan.md`
- `docs/AI_STATE.yml`

## Read Order

1. Read the task card.
2. Read requirements and design.
3. Read the implementation plan.
4. Read `docs/AI_STATE.yml`.

## Allowed Actions

- Run spec lint.
- Lock the plan.
- Start the current step.
- Check the active step allowlist.

## Forbidden Actions

- Do not edit implementation files before the plan is locked.
- Do not modify locked plans silently.
- Do not proceed when requirements or design are not approved.

## Commands

```bash
bash scripts/spec-lint.sh T-xxx
bash scripts/plan-lock.sh T-xxx
bash scripts/plan-step.sh T-xxx S-xxx --start
bash scripts/plan-guard.sh T-xxx S-xxx
```

## Expected Outputs

- `SPEC_LINT_PASS`
- `PLAN_LOCK_PASS`
- `PLAN_STEP_START`
- `PLAN_GUARD_PASS`

## Stop Conditions

- Spec lint fails.
- Requirements or design are not approved.
- The plan cannot be locked.
- The current step is missing or inconsistent with `docs/AI_STATE.yml`.
