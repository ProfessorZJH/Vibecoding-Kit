# Claude Code Bridge

Claude Code should use `CLAUDE.md`, `AGENTS.md`, and
`docs/ai/PLAN_PROTOCOL.md`.

## Recommended Flow

1. Use Claude Code todos for active execution tracking.
2. Use sub-agents only for work that stays inside the task card scope.
3. Copy the final plan into `docs/tasks/T-xxx.md` before implementation.
4. Run `bash scripts/ai-preflight.sh T-xxx`.
5. Run `bash scripts/drift-guard.sh`.
6. Run `bash scripts/task-closeout.sh T-xxx --write-report`.

If a Claude Code todo or sub-agent result conflicts with the task card, update
the task card first or stop as blocked.
