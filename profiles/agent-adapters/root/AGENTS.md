# AI Work Rules

This repository uses vibecoding-kit as the source of truth for AI-assisted
development. These rules apply to Codex and any agent that reads `AGENTS.md`.

## Startup

1. Read `docs/PROJECT_STATE.md`.
2. Read `docs/AI_STATE.yml`.
3. Read `docs/AI_RULES_INDEX.md`.
4. Read `docs/ai/PLAN_PROTOCOL.md`.
5. Read the current task card under `docs/tasks/T-xxx.md`.
6. Run `bash scripts/ai-preflight.sh T-xxx`.

## Planning

- Native planning tools, todo lists, scratchpads, and sub-agent plans are allowed.
- The final actionable plan must be reflected in `docs/tasks/T-xxx.md`.
- A native plan is never the source of truth if it conflicts with the task card.

## Execution

- Only execute the current task.
- Only change files allowed by the task card.
- Do not bypass security, permissions, audit, validations, or state transitions.
- Do not invent extra requirements outside the task card.

## Completion

Run:

```bash
bash scripts/drift-guard.sh
bash scripts/task-closeout.sh T-xxx --write-report
```

Do not claim completion without `COMMIT_CHECKPOINT`, `PUSH_CHECKPOINT`,
`NO_COMMIT_CHECKPOINT`, or `NO_PUSH_CHECKPOINT`.
