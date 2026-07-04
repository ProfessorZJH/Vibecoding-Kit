# Vibecoding Kit Agent Contract

You are an AI coding agent working inside a repository governed by Vibecoding
Kit.

The repository is the source of truth. Chat history is secondary. Before task
execution, inspect and follow repository state.

## Source Of Truth

Before making decisions, read:

1. `docs/AI_STATE.yml`
2. the current task card under `docs/tasks/`
3. related files under `docs/specs/`
4. related files under `docs/designs/`
5. related files under `docs/plans/`
6. `docs/VIBECODING_WORKFLOW.md` if present

If these files disagree with chat context, trust repository files first and
report the conflict.

## Current Task Discipline

Only work on the current task and current step recorded in
`docs/AI_STATE.yml`.

Respect:

- `current_task`
- `current_step`
- `workflow_status`
- `plan_status`
- `plan_hash`
- `require_plan_guard`
- `require_step_commit`
- `require_commit`
- `forbidden_paths`

Do not expand task scope without a plan update and relock. Do not silently fix
unrelated files. Do not perform opportunistic refactors.

Do not update dependencies, runtime configuration, CI workflows, database
migrations, security configuration, or deployment files unless the current plan
step explicitly allows them.

## Guard-First Principle

Prompts are soft guidance. Guard scripts are hard constraints.

Work must be compatible with:

- `scripts/plan-guard.sh`
- `scripts/drift-guard.sh`
- `scripts/secrets-guard.sh`
- `scripts/task-closeout.sh`
- future command, risk, or policy guards

If a guard fails, stop and explain the failure. Do not bypass the guard.

## File Safety

Never read, print, modify, move, or delete secret-bearing files.

Treat these as forbidden unless explicitly approved by policy:

- `.env`
- `.env.*`
- `*.pem`
- `*.key`
- `id_rsa`
- `id_ed25519`
- cloud credentials
- SSH credentials
- npm, pip, Docker, or Kubernetes credentials
- token files
- certificate private keys

Do not edit generated or local environment directories directly:

- `target/`
- `build/`
- `dist/`
- `node_modules/`
- `.idea/`
- `.m2home/`

## Command Safety

Run the smallest necessary command.

Prefer read-only commands during exploration and planning.

Never run commands that:

- download and execute remote scripts
- print secrets
- access SSH or cloud credentials
- modify system directories
- change broad file permissions
- push to remote unless explicitly requested
- install dependencies unless the current step explicitly allows it

## Implementation Rules

Before editing any file, verify:

1. the plan is locked
2. the current step is active
3. the file is allowed by the current step
4. the file is not forbidden by the current step
5. the change is necessary for the task
6. there is a test or verification path

If a required file is outside the allowed scope, stop and request a plan update.

## Output Discipline

When reporting work, include:

- task id
- step id
- files changed
- tests run
- guard status
- risks found
- unresolved issues
- next action

Do not claim a guard passed unless it actually ran. Do not claim tests passed
unless they actually ran. Do not invent files, commits, reports, or command
output.
