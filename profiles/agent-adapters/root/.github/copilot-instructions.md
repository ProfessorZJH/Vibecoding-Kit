# GitHub Copilot Instructions

Use the vibecoding-kit protocol for every coding task.

Before editing, read:

- `docs/AI_STATE.yml`
- `docs/VIBECODING_WORKFLOW.md`
- `docs/AI_RULES_INDEX.md`
- `docs/ai/PLAN_PROTOCOL.md`
- `workflows/README.md`
- the current `docs/tasks/T-xxx.md`
- related specs, designs, and plans

Use the shared prompt modules:

- `prompts/00-agent-contract.md`
- `prompts/02-plan-locked-task.md`
- `prompts/03-implement-current-step.md`
- `prompts/05-security-review.md`
- `prompts/06-closeout-report.md`

Then run:

```bash
bash scripts/ai-preflight.sh T-xxx
```

Copilot chat plans are not the source of truth. The final scope and acceptance
criteria must live in repository task and plan files.
Use `workflows/README.md` to choose the current phase workflow.

Before claiming completion, run:

```bash
bash scripts/drift-guard.sh
bash scripts/task-closeout.sh T-xxx --write-report
```
