# AI Work Rules

This project uses file-based vibecoding discipline. Every AI model, new window,
sub-agent, and worktree must read project files before development.

## Startup Order

1. `docs/PROJECT_STATE.md`
2. `docs/AI_STATE.yml`
3. `docs/AI_RULES_INDEX.md`
4. `docs/VIBECODING_WORKFLOW.md`
5. `workflows/README.md`
6. Current task card: `docs/tasks/T-xxx.md`
7. Related files under `docs/specs/`, `docs/designs/`, and `docs/plans/`

Use the installed prompt modules for mode-specific behavior:

- `prompts/00-agent-contract.md`
- `prompts/01-explore-readonly.md`
- `prompts/02-plan-locked-task.md`
- `prompts/03-implement-current-step.md`
- `prompts/04-command-classifier.md`
- `prompts/05-security-review.md`
- `prompts/06-closeout-report.md`
- `prompts/07-task-memory-summary.md`

Use installed workflow modules for phase-specific execution:

- `workflows/project-scan.md`
- `workflows/task-create.md`
- `workflows/plan-lock.md`
- `workflows/implement-step.md`
- `workflows/risk-review.md`
- `workflows/closeout.md`

After reading the task card, run:

```bash
bash scripts/ai-preflight.sh T-xxx
```

## Execution Discipline

- Only execute the current task.
- Only modify files allowed by the task card.
- Do not add unapproved requirements.
- Do not bypass security, permissions, audit, validations, or state transitions.
- Do not claim completion without `COMMIT_CHECKPOINT`, `PUSH_CHECKPOINT`,
  `NO_COMMIT_CHECKPOINT`, or `NO_PUSH_CHECKPOINT`.

## Completion

Run:

```bash
bash scripts/drift-guard.sh
bash scripts/task-closeout.sh T-xxx
```

If information is missing, output:

```txt
BLOCKED
reason:
needs:
suggested_next_step:
```
