# AI Work Rules

This project uses file-based vibecoding discipline. Every AI model, new window,
sub-agent, and worktree must read project files before development.

## Startup Order

1. `docs/PROJECT_STATE.md`
2. `docs/AI_STATE.yml`
3. `docs/AI_RULES_INDEX.md`
4. Current task card: `docs/tasks/T-xxx.md`

After reading the task card, run:

```bash
bash scripts/ai-preflight.sh T-xxx
```

## Execution Discipline

- Only execute the current task.
- Only modify files allowed by the task card.
- Do not add unapproved requirements.
- Do not bypass security, permissions, audit, validations, or state transitions.
- Do not claim completion without `COMMIT_CHECKPOINT`, `PUSH_CHECKPOINT`,
  `NO_COMMIT_CHECKPOINT`, or `NO_PUSH_CHECKPOINT`.

## Completion

Run:

```bash
bash scripts/drift-guard.sh
bash scripts/task-closeout.sh T-xxx
```

If information is missing, output:

```txt
BLOCKED
reason:
needs:
suggested_next_step:
```
