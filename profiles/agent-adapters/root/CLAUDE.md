# Claude Code Protocol

Claude Code must use the repository files as the source of truth.

## Required Startup

1. Read `AGENTS.md`.
2. Read `docs/PROJECT_STATE.md`.
3. Read `docs/AI_STATE.yml`.
4. Read `docs/AI_RULES_INDEX.md`.
5. Read `docs/ai/PLAN_PROTOCOL.md`.
6. Read the current task card under `docs/tasks/T-xxx.md`.
7. Run `bash scripts/ai-preflight.sh T-xxx`.

## Planning Compatibility

Claude Code plans, todos, and sub-agent plans are useful working tools, but the
project plan must be written back to `docs/tasks/T-xxx.md` before execution.
If a Claude Code plan conflicts with the task card, follow the task card.

## Closeout

Run:

```bash
bash scripts/drift-guard.sh
bash scripts/task-closeout.sh T-xxx --write-report
```

Report the git and push checkpoint from closeout.
