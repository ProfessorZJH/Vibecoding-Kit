# Task Create Workflow

## Purpose

Create or update repository source-of-truth files before implementation starts.

## Inputs

- User request or issue description.
- Existing project rules.
- Existing task, spec, design, and plan templates.
- Relevant repository context from `project-scan.md`.

## Read Order

1. Read `docs/AI_RULES_INDEX.md`.
2. Read `docs/TASK_TEMPLATE.md` when available.
3. Read existing `docs/tasks/` examples.
4. Read existing `docs/specs/`, `docs/designs/`, and `docs/plans/` examples.
5. Inspect relevant source files only as needed to define scope.

## Allowed Actions

- Create or update one task card.
- Create or update the matching requirements, design, and plan files.
- Define allowed changes, forbidden changes, commands, expected outputs, and
  completion criteria.
- Keep the plan small enough for guardable steps.

## Forbidden Actions

- Do not implement product or guard behavior.
- Do not edit files outside the task source-of-truth set.
- Do not add unapproved requirements.
- Do not create a parallel workflow outside Vibecoding Kit files.

## Commands

```bash
bash scripts/spec-lint.sh T-xxx
git diff --check
```

## Expected Outputs

- `docs/tasks/T-xxx.md`
- `docs/specs/T-xxx-requirements.md`
- `docs/designs/T-xxx-design.md`
- `docs/plans/T-xxx-plan.md`
- `SPEC_LINT_PASS`

## Stop Conditions

- Requirements are ambiguous enough that allowed changes cannot be defined.
- The task spans multiple independent projects and needs decomposition.
- Required approvals are missing.
