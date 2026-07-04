# Codex Bridge

Codex should treat `AGENTS.md` and `docs/ai/PLAN_PROTOCOL.md` as the operating
protocol.

## Recommended Flow

1. Read startup files.
2. Use Codex planning for local task tracking when useful.
3. Write the final scope into `docs/tasks/T-xxx.md`.
4. Run `bash scripts/ai-preflight.sh T-xxx`.
5. Implement only the allowed task scope.
6. Run closeout commands.
7. Commit and push when requested and allowed.

Codex plans are helpful, but they are not the source of truth.

Before implementation, convert the tool's native plan into the locked plan engine contract.
Native todos, modes, and plan panes are scratch state; the portable contract is
`docs/plans/T-xxx-plan.md` plus `docs/AI_STATE.yml`.
