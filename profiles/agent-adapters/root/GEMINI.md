# Gemini CLI Protocol

Gemini must treat Vibecoding Kit files as the execution protocol.

## Startup

1. Read `docs/AI_STATE.yml`.
2. Read `docs/VIBECODING_WORKFLOW.md`.
3. Read `docs/AI_RULES_INDEX.md`.
4. Read `docs/ai/PLAN_PROTOCOL.md`.
5. Read `docs/tasks/T-xxx.md`.
6. Read related specs, designs, and plans.
7. Run `bash scripts/ai-preflight.sh T-xxx`.

## Prompt Modules

Follow:

- `prompts/00-agent-contract.md`
- `prompts/01-explore-readonly.md`
- `prompts/02-plan-locked-task.md`
- `prompts/03-implement-current-step.md`
- `prompts/04-command-classifier.md`
- `prompts/05-security-review.md`
- `prompts/06-closeout-report.md`
- `prompts/07-task-memory-summary.md`

## Native Planning

Gemini plans are allowed as scratch work. Before changing files, copy the final
scope, allowed files, tests, and completion criteria into repository task and
plan files.

## Completion

Run `bash scripts/drift-guard.sh` and
`bash scripts/task-closeout.sh T-xxx --write-report`. Do not claim tests or
guards passed unless they actually ran.
