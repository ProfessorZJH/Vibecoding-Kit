<!-- VIBECODING-KIT:BEGIN -->
# __PROJECT_NAME__ - AI Execution Protocol

Every AI model must complete startup before changing files.

## Startup

1. Read `AGENTS.md`.
2. Read `docs/PROJECT_STATE.md`.
3. Read `docs/AI_STATE.yml`.
4. Read `docs/AI_RULES_INDEX.md`.
5. Read `docs/VIBECODING_WORKFLOW.md`.
6. Read `workflows/README.md`.
7. Read the current task card.
8. Read related specs, designs, and plans.
9. Run `bash scripts/ai-preflight.sh T-xxx`.

## Prompt Modules

Use:

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

## Iron Rules

- Do not execute work outside the current task.
- Do not modify unauthorized files.
- Do not skip tests or guard scripts.
- Do not claim completion while task changes are uncommitted unless
  `NO_COMMIT_CHECKPOINT` is reported.
- Do not push protected branches without explicit user approval.
<!-- VIBECODING-KIT:END -->
