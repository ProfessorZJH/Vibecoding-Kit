# __PROJECT_NAME__ - AI Execution Protocol

Every AI model must complete startup before changing files.

## Startup

1. Read `AGENTS.md`.
2. Read `docs/PROJECT_STATE.md`.
3. Read `docs/AI_STATE.yml`.
4. Read `docs/AI_RULES_INDEX.md`.
5. Read the current task card.
6. Run `bash scripts/ai-preflight.sh T-xxx`.

## Iron Rules

- Do not execute work outside the current task.
- Do not modify unauthorized files.
- Do not skip tests or guard scripts.
- Do not claim completion while task changes are uncommitted unless
  `NO_COMMIT_CHECKPOINT` is reported.
- Do not push protected branches without explicit user approval.
