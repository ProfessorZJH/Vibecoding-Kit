# GitHub Copilot Instructions

Use the vibecoding-kit protocol for every coding task.

Before editing, read:

- `docs/PROJECT_STATE.md`
- `docs/AI_STATE.yml`
- `docs/AI_RULES_INDEX.md`
- `docs/ai/PLAN_PROTOCOL.md`
- the current `docs/tasks/T-xxx.md`

Then run:

```bash
bash scripts/ai-preflight.sh T-xxx
```

Copilot chat plans are not the source of truth. The final scope and acceptance
criteria must live in `docs/tasks/T-xxx.md`.

Before claiming completion, run:

```bash
bash scripts/drift-guard.sh
bash scripts/task-closeout.sh T-xxx --write-report
```
