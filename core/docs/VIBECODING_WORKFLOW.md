# Vibecoding Workflow

This project uses Vibecoding Kit. The repository files are the source of truth
for AI-assisted development.

## Start Every Task

```bash
bash scripts/ai-preflight.sh T-xxx
```

Read these files before implementation:

- `docs/AI_STATE.yml`
- `docs/AI_RULES_INDEX.md`
- `prompts/00-agent-contract.md`
- `docs/tasks/T-xxx.md`
- `docs/specs/T-xxx-requirements.md`
- `docs/designs/T-xxx-design.md`
- `docs/plans/T-xxx-plan.md`

## Lock Before Implementation

```bash
bash scripts/spec-lint.sh T-xxx
bash scripts/plan-lock.sh T-xxx
bash scripts/plan-guard.sh T-xxx S-xxx
```

Implementation must only change files allowed by the current plan step. Native
AI plans and todo lists are allowed, but they must match the repository plan.

## Use Prompt Modes

Use the installed prompts as mode-specific guidance:

- `prompts/01-explore-readonly.md` for read-only exploration.
- `prompts/02-plan-locked-task.md` for guard-checkable planning.
- `prompts/03-implement-current-step.md` for scoped implementation.
- `prompts/06-closeout-report.md` for completion reporting.

## Complete A Step

```bash
bash scripts/plan-step.sh T-xxx S-xxx --start
# edit only files allowed by S-xxx
git add .
git commit -m "T-xxx: describe the step"
bash scripts/plan-step.sh T-xxx S-xxx --complete
```

If the current step requires a commit, completion fails until a matching local
commit exists and the working tree is clean.

## Close Out

```bash
bash scripts/drift-guard.sh
bash scripts/task-closeout.sh T-xxx --write-report
```

To push after closeout:

```bash
bash scripts/task-closeout.sh T-xxx --write-report --push
```

Push depends on a configured remote, credentials, branch policy, and explicit
intent.

## If The Plan Is Wrong

Stop and report:

```txt
PLAN_CHANGE_REQUIRED
reason:
requested_change:
affected_files:
suggested_plan_update:
```

Do not keep editing outside the locked plan.
