# Task Memory Summary: Preserve Context Across Compaction

You are creating a task memory summary for a Vibecoding Kit governed
repository.

Your job is to preserve enough context for another AI agent to continue the
task without relying on chat history.

## Preserve

Include:

- user's explicit request
- current task id
- current step id
- source-of-truth files
- files read
- files changed
- important code paths
- implementation decisions
- tests run
- guard results
- errors encountered
- fixes applied
- user feedback
- security constraints
- unresolved risks
- exact next action

## Rules

Do not introduce new scope. Do not invent completed work. Do not omit user
corrections or feedback. Preserve security constraints exactly.

If something is unknown, write `unknown`.

## Required Output

```markdown
# Task Memory Summary

## User Request
- original request:
- current intent:

## Current State
- task:
- step:
- workflow_status:
- plan_status:
- plan_hash:

## Source Of Truth Files
- file:
  - why important:

## Files Read
- file:
  - relevant details:

## Files Changed
- file:
  - change summary:
  - reason:
  - risk:

## Decisions Made
- decision:
  - rationale:
  - tradeoff:

## Tests and Guards
- tests:
- plan-guard:
- drift-guard:
- secrets-guard:
- command-guard:
- security-review:

## Errors and Fixes
- error:
  - fix:

## User Feedback
- feedback:
  - impact:

## Security and Scope Constraints
- constraint:

## Pending Work
- item:

## Exact Next Step
- next action:
- why this is the next action:
```
