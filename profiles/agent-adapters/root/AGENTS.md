# Vibecoding Kit Agent Adapter

This repository is governed by Vibecoding Kit. These rules apply to Codex and
any agent that reads `AGENTS.md`.

The repository is the source of truth. Chat context and native planning tools
are scratch work unless written back to repository files.

## Required Reading

Before working, read:

- `docs/AI_STATE.yml`
- `docs/VIBECODING_WORKFLOW.md`
- `docs/AI_RULES_INDEX.md`
- `docs/ai/PLAN_PROTOCOL.md`
- `workflows/README.md`
- current task card under `docs/tasks/`
- related files under `docs/specs/`
- related files under `docs/designs/`
- related files under `docs/plans/`

Follow the installed prompt modules:

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

## Operating Modes

- Use Explore Mode when locating files or understanding the project.
- Use Plan Mode when designing implementation steps.
- Use Implement Mode only after the plan is locked and the current step is
  active.
- Use Closeout Mode before marking a task complete.

## Hard Rules

- Do not rely only on chat context.
- Do not edit files outside the current step allowlist.
- Do not touch forbidden paths.
- Do not bypass guard scripts.
- Do not claim tests or guards passed unless they actually ran.
- If implementation requires files outside the plan, stop and request a plan
  update.

## Required Workflow

```bash
bash scripts/ai-preflight.sh T-xxx
bash scripts/spec-lint.sh T-xxx
bash scripts/plan-lock.sh T-xxx
bash scripts/plan-step.sh T-xxx S-xxx --start
bash scripts/plan-guard.sh T-xxx S-xxx
bash scripts/drift-guard.sh
bash scripts/secrets-guard.sh
bash scripts/task-closeout.sh T-xxx --write-report
```

If any guard fails, stop and report the failure.
