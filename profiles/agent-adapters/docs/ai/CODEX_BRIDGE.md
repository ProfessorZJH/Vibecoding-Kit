# Codex Bridge

Codex should treat `AGENTS.md`, `docs/ai/PLAN_PROTOCOL.md`, and
`workflows/README.md` as the operating protocol.

## Recommended Flow

1. Read startup files.
2. Choose the current phase from `workflows/README.md`.
3. Use Codex planning for local task tracking when useful.
4. Write the final scope into `docs/tasks/T-xxx.md`.
5. Run `bash scripts/ai-preflight.sh T-xxx`.
6. Implement only the allowed task scope.
7. Run closeout commands.
8. Commit and push when requested and allowed.

Codex plans are helpful, but they are not the source of truth.

Before implementation, convert the tool's native plan into the locked plan engine contract.
Native todos, modes, and plan panes are scratch state; the portable contract is
`docs/plans/T-xxx-plan.md` plus `docs/AI_STATE.yml`.
