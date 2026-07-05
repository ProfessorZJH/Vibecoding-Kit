# Project Scan Workflow

## Purpose

Understand the repository, active task, rules, and likely impact area before
planning or editing.

## Inputs

- `docs/AI_STATE.yml`
- `docs/PROJECT_STATE.md`
- `docs/AI_RULES_INDEX.md`
- `docs/VIBECODING_WORKFLOW.md`
- Current task card under `docs/tasks/`
- Related files under `docs/specs/`, `docs/designs/`, and `docs/plans/`

## Read Order

1. Read `docs/AI_STATE.yml`.
2. Read `docs/PROJECT_STATE.md`.
3. Read `docs/AI_RULES_INDEX.md`.
4. Read `docs/VIBECODING_WORKFLOW.md`.
5. Read the current task card.
6. Read related specs, designs, and plans.
7. Inspect relevant source and test files.

## Allowed Actions

- Read files.
- Search with `rg`, `find`, `git status`, `git diff`, and `git log`.
- Summarize relevant paths and risks.
- Identify missing source-of-truth files.

## Forbidden Actions

- Do not edit files.
- Do not install dependencies.
- Do not run migrations, formatters, or generators.
- Do not commit or change branches.

## Commands

```bash
git status --short --branch
rg --files
bash scripts/ai-preflight.sh T-xxx
```

## Expected Outputs

- Current task and current step.
- Source-of-truth files read.
- Relevant code paths.
- Known risks and missing information.

## Stop Conditions

- Required source-of-truth files are missing.
- Current task is unknown.
- The requested work conflicts with the current task card or locked plan.
