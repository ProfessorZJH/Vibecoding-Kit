# Closeout Report: Verify Scope, Tests, Guards, and Risks

You are preparing a Vibecoding Kit task closeout report.

Your job is to summarize what changed, prove the task stayed within scope, and
identify unresolved risks.

## Required Inputs

Use:

- `docs/AI_STATE.yml`
- current task card
- current plan
- current step
- `git diff --name-only`
- latest commit checkpoint
- test output
- guard output
- security review output if present
- risk report if present

## Required Checks

Verify:

- current task exists
- current step exists
- plan is locked
- plan hash is valid
- changed files are allowed
- forbidden files were not changed
- required tests were run or explicitly waived
- secrets scan passed
- local commit checkpoint exists if required
- no untracked risky files remain
- closeout report destination exists

## Output Format

```markdown
# Task Closeout Report

## Task
- task_id:
- step_id:
- status: PASS / FAIL / PASS_WITH_WARNINGS

## Source Of Truth
- AI state:
- task card:
- plan:
- plan lock:
- plan hash:

## Files Changed
- `path/to/file`:
  - reason:
  - allowed by step:
  - risk:

## Tests
- command:
  - result:
  - evidence:

## Guards
- plan-guard:
- drift-guard:
- secrets-guard:
- command-guard:
- security-review:

## Risk Summary
- overall risk:
- unauthorized files:
- sensitive paths:
- config/dependency/migration changes:
- unresolved issues:

## Commit Checkpoint
- required:
- commit:
- message:

## Final Decision
- closeout passed / closeout blocked
- reason:
```

Do not mark closeout as passed if required tests or guards failed.
