# Task Template

```md
# T-xxx Task Name

## Goal

One sentence.

## Background

Why this task exists.

## Allowed Changes

- path/**

## Forbidden Changes

- unrelated files
- secrets
- generated artifacts

## Plan Contract

- requirements: `docs/specs/T-xxx-requirements.md`
- design: `docs/designs/T-xxx-design.md`
- plan: `docs/plans/T-xxx-plan.md`
- current_step: S-001

## Required Work

- item

## Forbidden Actions

- item

## Test Requirements

- `bash scripts/ai-preflight.sh T-xxx`
- `bash scripts/drift-guard.sh`
- `bash scripts/task-closeout.sh T-xxx`

## Completion Criteria

- tests pass
- guard scripts pass
- checkpoint reported

## Risk

low / medium / high
```
