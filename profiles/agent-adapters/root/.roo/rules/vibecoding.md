# Vibecoding Protocol

Roo must treat repository files as the source of truth.

Before edits:

```bash
bash scripts/ai-preflight.sh T-xxx
```

Read:
- `docs/AI_STATE.yml`
- `docs/VIBECODING_WORKFLOW.md`
- `docs/ai/PLAN_PROTOCOL.md`
- current task, spec, design, and plan files

Use shared prompt modules:
- `prompts/00-agent-contract.md`
- `prompts/01-explore-readonly.md`
- `prompts/02-plan-locked-task.md`
- `prompts/03-implement-current-step.md`
- `prompts/07-task-memory-summary.md`

Roo modes and planning are scratch work unless written back to the task card.
If Roo's internal plan conflicts with repository files, follow repository files.

Before completion:

```bash
bash scripts/drift-guard.sh
bash scripts/task-closeout.sh T-xxx --write-report
```
