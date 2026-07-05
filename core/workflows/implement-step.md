# Implement Step Workflow

## Purpose

Implement only the files allowed by the active locked plan step.

## Inputs

- Current task card.
- Locked plan.
- Current step from `docs/AI_STATE.yml`.
- Relevant source and test files.

## Read Order

1. Read `docs/AI_STATE.yml`.
2. Read the current task card.
3. Read the current step in `docs/plans/T-xxx-plan.md`.
4. Read relevant implementation files.
5. Read relevant tests.

## Allowed Actions

- Edit files listed in the current step allowlist.
- Run commands listed in the current plan step.
- Add focused tests or documentation when allowed by the current step.
- Commit when the step requires a checkpoint.

## Forbidden Actions

- Do not edit files outside the current step allowlist.
- Do not touch forbidden paths.
- Do not change scope after lock without reporting `PLAN_CHANGE_REQUIRED`.
- Do not claim command, test, or guard success without running the command.

## Commands

```bash
bash scripts/plan-guard.sh T-xxx S-xxx
# run the step-specific test commands from docs/plans/T-xxx-plan.md
git add .
git commit -m "T-xxx: describe the step"
bash scripts/plan-step.sh T-xxx S-xxx --complete
```

## Expected Outputs

- Changed files match the current step allowlist.
- Required tests pass.
- Required commit checkpoint exists when requested.
- `PLAN_STEP_COMPLETE`

## Stop Conditions

- A needed file is outside the allowlist.
- A forbidden file would need to change.
- Tests or guards fail.
- The latest commit does not satisfy a required checkpoint.
