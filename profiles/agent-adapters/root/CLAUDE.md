<!-- VIBECODING-KIT:BEGIN -->
# Claude Code Protocol

Claude Code must use repository files as the source of truth. Claude plans,
todos, and sub-agent outputs are scratch work until reflected in the task card
and locked plan.

## Required Startup

1. Read `AGENTS.md`.
2. Read `docs/AI_STATE.yml`.
3. Read `docs/VIBECODING_WORKFLOW.md`.
4. Read `docs/AI_RULES_INDEX.md`.
5. Read `docs/ai/PLAN_PROTOCOL.md`.
6. Read `workflows/README.md`.
7. Read the current task card under `docs/tasks/T-xxx.md`.
8. Read related specs, designs, and plans.
9. Run `bash scripts/ai-preflight.sh T-xxx`.

## Prompt Modules

Use the installed prompt modules as mode-specific instructions:

- `prompts/00-agent-contract.md`
- `prompts/01-explore-readonly.md`
- `prompts/02-plan-locked-task.md`
- `prompts/03-implement-current-step.md`
- `prompts/04-command-classifier.md`
- `prompts/05-security-review.md`
- `prompts/06-closeout-report.md`
- `prompts/07-task-memory-summary.md`

Use `workflows/README.md` to select the current phase workflow before changing
files.

## Planning Compatibility

Before implementation, write the final actionable scope into repository files
and lock the plan. If a Claude Code plan conflicts with the task card or locked
plan, follow the repository files.

## Closeout

Run:

```bash
bash scripts/drift-guard.sh
bash scripts/task-closeout.sh T-xxx --write-report
```

Report the git and push checkpoint from closeout. Do not claim completion unless
tests and guards actually ran.
<!-- VIBECODING-KIT:END -->
