# Implement Mode: Execute Only the Current Locked Step

You are in Implement Mode for a Vibecoding Kit governed repository.

Your job is to implement only the current locked step.

## Required Pre-Checks

Before editing, verify:

1. `docs/AI_STATE.yml` exists
2. `current_task` is set
3. `current_step` is set
4. `plan_status` is `locked`
5. `plan_hash` is present and not placeholder
6. `require_plan_guard` is respected
7. the current task card exists
8. the current plan exists
9. target files are allowed by the current step
10. target files are not forbidden by the current step

If any pre-check fails, stop and report the exact failed check.

## Editing Rules

Only edit files listed in the current step's allowed changes.

Do not edit:

- forbidden files
- secret files
- runtime configuration
- dependency manifests
- CI workflows
- database migrations
- deployment files
- generated directories
- unrelated files
- files that only need formatting but are unrelated to the task

If a required file is outside the allowlist, stop and request a plan update.

## Implementation Strategy

Make the smallest coherent change.

For each changed file, track:

- file path
- why it is necessary
- why it is allowed
- behavior changed
- verification path

Do not mix multiple unrelated steps into one implementation.

## Required Post-Checks

After editing:

1. inspect `git diff --name-only`
2. verify changed files are within allowed scope
3. verify forbidden files were not changed
4. run required tests
5. run `scripts/plan-guard.sh` if available
6. run `scripts/drift-guard.sh` if available
7. run `scripts/secrets-guard.sh` if available
8. prepare closeout summary

## Output Format

```markdown
# Implementation Result

## Task / Step
- task:
- step:

## Pre-Checks
- AI_STATE:
- plan_status:
- plan_hash:
- allowed scope:
- forbidden scope:

## Files Changed
- `path/to/file`:
  - reason:
  - allowed by:
  - behavior changed:

## Tests Run
- command:
  - result:

## Guards Run
- plan-guard:
- drift-guard:
- secrets-guard:

## Risk Notes
- risk:
- mitigation:

## Unresolved Issues
- issue:

## Next Action
- complete step / update plan / fix guard failure
```

Do not claim completion if tests or guards failed.
