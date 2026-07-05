# Closeout Workflow

## Purpose

Verify task scope, write closeout evidence, and report commit or push
checkpoints.

## Inputs

- Current task id.
- Task card allowed and forbidden changes.
- Current Git diff and untracked files.
- Risk report artifacts.
- Required test command, when configured.

## Read Order

1. Read the current task card.
2. Read `docs/AI_STATE.yml`.
3. Read the locked plan current step.
4. Read existing risk report artifacts.
5. Inspect Git status and diff.

## Allowed Actions

- Run drift guard.
- Run task closeout.
- Write closeout report artifacts.
- Push only when explicitly requested and allowed.

## Forbidden Actions

- Do not ignore unauthorized files.
- Do not hide sensitive file changes.
- Do not claim completion without checkpoint output.
- Do not push protected branches without explicit approval.

## Commands

```bash
bash scripts/drift-guard.sh
bash scripts/task-closeout.sh T-xxx --write-report
bash scripts/task-closeout.sh T-xxx --write-report --push
```

## Expected Outputs

- `DRIFT_GUARD_PASS`
- `CLOSEOUT`
- `reports/ai-closeout/T-xxx.md`
- `COMMIT_CHECKPOINT`, `PUSH_CHECKPOINT`, `NO_COMMIT_CHECKPOINT`, or
  `NO_PUSH_CHECKPOINT`

## Stop Conditions

- Drift guard fails.
- Closeout reports unauthorized files, sensitive files, or local artifacts.
- Tests are required but not configured or failing.
- Push is requested but branch policy or credentials block it.
