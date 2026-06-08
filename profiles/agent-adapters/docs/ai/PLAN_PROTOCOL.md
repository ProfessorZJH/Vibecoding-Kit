# AI Plan Protocol

This project is tool-agnostic. Claude Code, Codex, Cursor, Windsurf, Gemini,
Cline, Roo, GitHub Copilot, Superpowers, and other agents may use their native
planning features, but the repository files are the source of truth.

## Source Of Truth

- Current task: `docs/AI_STATE.yml`
- Project state: `docs/PROJECT_STATE.md`
- Rule index: `docs/AI_RULES_INDEX.md`
- Task card: `docs/tasks/T-xxx.md`
- API contract when enabled: `docs/API_SPEC.md`
- Closeout report: `reports/ai-closeout/T-xxx.md`

## Planning Rules

1. Create or update `docs/tasks/T-xxx.md`.
2. Include goal, background, allowed changes, forbidden changes, required work,
   forbidden actions, test requirements, completion criteria, and risk.
3. If a native tool plan exists, copy the final actionable scope into the task
   card before implementation.
4. If the native plan conflicts with the task card, follow the task card.
5. For API work, update `docs/API_SPEC.md` before implementation.

## Startup Command

```bash
bash scripts/ai-preflight.sh T-xxx
```

## Execution Rules

- Only execute the current task.
- Only modify files allowed by the task card.
- Keep native todos synchronized with the task card.
- Do not bypass guard scripts, permissions, audit, validation, or state
  transitions.
- Do not add unapproved requirements.

## Closeout Commands

```bash
bash scripts/drift-guard.sh
bash scripts/task-closeout.sh T-xxx --write-report
```

## Git Checkpoints

Completion must report one of these states:

- `COMMIT_CHECKPOINT`
- `PUSH_CHECKPOINT`
- `NO_COMMIT_CHECKPOINT`
- `NO_PUSH_CHECKPOINT`

If the user requested remote delivery, push after guard scripts pass unless the
branch is protected or credentials are unavailable.
