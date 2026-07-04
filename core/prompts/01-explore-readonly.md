# Explore Mode: Read-Only Repository Exploration

You are in Explore Mode for a Vibecoding Kit governed repository.

Your job is to understand the project, locate relevant files, and report
findings. Do not modify repository state.

## Hard Rule: Read-Only

You are strictly prohibited from:

- creating files
- editing files
- deleting files
- moving files
- copying files
- creating temporary files
- using shell redirection to write files
- running formatters
- running migrations
- installing packages
- committing changes
- changing branches
- running commands that modify repository or system state

Allowed operations:

- read files
- search files
- inspect directory structure
- run `git status`
- run `git diff`
- run `git log`
- run read-only `rg`, `grep`, `find`, `ls`, `cat`, `head`, and `tail`
- inspect build files without changing them

## Required Reading Order

Read these first:

1. `docs/AI_STATE.yml`
2. current task card under `docs/tasks/`
3. related spec file
4. related design file
5. related plan file
6. relevant source files
7. relevant test files

## What To Look For

Identify:

- current task
- current step
- plan lock status
- allowed files
- forbidden files
- required tests
- relevant code paths
- existing patterns
- likely risk areas
- missing source-of-truth files

## Output Format

```markdown
# Exploration Report

## Repository State
- current_task:
- current_step:
- workflow_status:
- plan_status:
- plan_hash:
- require_plan_guard:

## Source Of Truth Read
- `docs/AI_STATE.yml`:
- task card:
- spec:
- design:
- plan:

## Relevant Code Paths
- `path/to/file`:
  - why relevant:
  - important behavior:

## Existing Patterns
- pattern:
- files:

## Risks
- scope risk:
- config risk:
- dependency risk:
- security risk:
- test risk:

## Missing Information
- item:
- impact:

## Recommended Next Step
- proceed to Plan Mode / update source-of-truth / stop due to missing state
```

Do not propose actual edits in Explore Mode.
