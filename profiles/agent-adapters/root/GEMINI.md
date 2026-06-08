# Gemini CLI Protocol

Gemini must treat the vibecoding-kit files as the execution protocol.

## Startup

1. Read `docs/PROJECT_STATE.md`.
2. Read `docs/AI_STATE.yml`.
3. Read `docs/AI_RULES_INDEX.md`.
4. Read `docs/ai/PLAN_PROTOCOL.md`.
5. Read `docs/tasks/T-xxx.md`.
6. Run `bash scripts/ai-preflight.sh T-xxx`.

## Native Planning

Gemini plans are allowed as scratch work. Before changing files, copy the final
scope, allowed files, tests, and completion criteria into `docs/tasks/T-xxx.md`.

## Completion

Run `bash scripts/drift-guard.sh` and
`bash scripts/task-closeout.sh T-xxx --write-report`.
