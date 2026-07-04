# Plan Mode: Create a Guard-Checkable Implementation Plan

You are in Plan Mode for a Vibecoding Kit governed repository.

Your job is to create or update an implementation plan that can be locked and
verified by guard scripts. Do not modify source files in Plan Mode.

## Goal

Produce a plan that can be checked by:

- `scripts/plan-lock.sh`
- `scripts/plan-step.sh`
- `scripts/plan-guard.sh`
- `scripts/drift-guard.sh`
- `scripts/task-closeout.sh`

The plan must be precise enough that changed files can be compared against the
current step.

## Inputs

Use:

- `docs/AI_STATE.yml`
- current task card
- related spec
- related design
- existing plan
- exploration findings
- relevant source files
- existing tests

## Planning Rules

Each step must define:

- step id
- goal
- allowed changes
- forbidden changes
- required tests
- risk level
- completion criteria
- rollback notes

Prefer exact file paths over broad globs. If a file may be needed but is not
confirmed, put it under `needs_confirmation`, not `allowed_changes`.

Do not allow dependency, config, CI, database, or deployment changes unless the
task explicitly requires them.

## Risk Levels

- LOW: business logic, tests, docs for the current task
- MEDIUM: scripts, local tooling, non-runtime configuration
- HIGH: dependency manifests, runtime config, CI, Docker, migrations
- CRITICAL: secrets, credentials, auth, permissions, production deployment,
  destructive commands

## Required Output

```markdown
# Implementation Plan

## Task
- task_id:
- current_step:
- source_of_truth_files:

## Requirements Summary
- requirement:

## Assumptions
- assumption:
  - confidence:
  - validation:

## Steps

### S-001: <step name>

Goal:

Allowed changes:
- `path/to/file`

Forbidden changes:
- `.env`
- `.env.*`
- `*.pem`
- `*.key`
- `id_rsa`
- `id_ed25519`
- `target/**`
- `.m2home/**`
- `.idea/**`
- `node_modules/**`

Required tests:
- command:

Risk level:
- LOW / MEDIUM / HIGH / CRITICAL

Completion criteria:
- criterion:

Rollback notes:
- note:

Needs confirmation:
- file or action:
  - why:

## Guard Inputs

allowed_changes:
- `path/to/file`

forbidden_changes:
- `path/to/file`

required_tests:
- command:

## Critical Files for Implementation

- `path/to/file1`
- `path/to/file2`
- `path/to/file3`

## Stop Conditions

Stop and update the plan if:

- implementation needs files outside `allowed_changes`
- forbidden files need to be touched
- dependency/config/migration/CI/deployment changes become necessary
- required tests cannot be run
- `docs/AI_STATE.yml` changes unexpectedly
- plan hash no longer matches
```

After this plan is accepted, it should be written into the task and plan files
and locked before implementation.
