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
