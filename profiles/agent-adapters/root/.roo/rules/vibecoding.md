# Vibecoding Protocol

Roo must treat `docs/tasks/T-xxx.md` and `docs/AI_STATE.yml` as the source of
truth.

Before edits:

```bash
bash scripts/ai-preflight.sh T-xxx
```

Roo modes and planning are scratch work unless written back to the task card.
If Roo's internal plan conflicts with `docs/tasks/T-xxx.md`, follow the task
card.

Before completion:

```bash
bash scripts/drift-guard.sh
bash scripts/task-closeout.sh T-xxx --write-report
```
