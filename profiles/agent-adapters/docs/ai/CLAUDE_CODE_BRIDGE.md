# Claude Code Bridge

Claude Code should use `CLAUDE.md`, `AGENTS.md`, `docs/ai/PLAN_PROTOCOL.md`,
and `workflows/README.md`.

## Recommended Flow

1. Use Claude Code todos for active execution tracking.
2. Choose the current phase from `workflows/README.md`.
3. Use sub-agents only for work that stays inside the task card scope.
4. Copy the final plan into `docs/tasks/T-xxx.md` before implementation.
5. Run `bash scripts/ai-preflight.sh T-xxx`.
6. Run `bash scripts/drift-guard.sh`.
7. Run `bash scripts/task-closeout.sh T-xxx --write-report`.

If a Claude Code todo or sub-agent result conflicts with the task card, update
the task card first or stop as blocked.

Before implementation, convert the tool's native plan into the locked plan engine contract.
Native todos, modes, and plan panes are scratch state; the portable contract is
`docs/plans/T-xxx-plan.md` plus `docs/AI_STATE.yml`.
