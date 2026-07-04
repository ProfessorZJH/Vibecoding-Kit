# Vibecoding Template Handbook

Vibecoding Kit is a reusable operating system for AI-assisted development. It is
designed to be installed into any new project, then used as the shared contract
between the human owner, the repository, and whichever AI coding agent is doing
the work.

## Project Model

The repository is the source of truth. Native AI plans are useful, but they are
not authoritative until they are copied into repository artifacts:

- `docs/specs/T-xxx-requirements.md`: problem, goals, non-goals, acceptance
  criteria, and risk.
- `docs/designs/T-xxx-design.md`: architecture, files, data flow, error
  handling, and tests.
- `docs/plans/T-xxx-plan.md`: step-by-step execution contract with allowed
  changes, forbidden changes, commands, expected output, and commit rules.
- `docs/tasks/T-xxx.md`: human-readable task card and closeout contract.
- `docs/VIBECODING_WORKFLOW.md`: installed workflow guide for the generated
  project.
- `docs/AI_STATE.yml`: machine-readable current task, current step, lock state,
  and checkpoint policy.

This lets Codex, Claude Code, Superpowers, Cursor, Cline, Roo, Windsurf, Gemini,
GitHub Copilot, and other tools use their own planning UI while still obeying
the same repository-level contract.

## Install Into A New Project

Minimal generic project:

```bash
bash installer/init.sh \
  --target /path/to/project \
  --name my-project \
  --profile agent-adapters \
  --ci none
```

Java/Spring + Vue + DDD finance project:

```bash
bash installer/init.sh \
  --target /path/to/project \
  --name my-project \
  --profile java-spring \
  --profile vue \
  --profile ddd \
  --profile finance \
  --profile api-contract \
  --profile agent-adapters \
  --ci gitcode \
  --ci github
```

DDD scaffold reference:

```bash
bash installer/init.sh \
  --target /path/to/project \
  --name my-project \
  --profile ddd \
  --apply-xfg-scaffold \
  --group-id com.example \
  --package com.example
```

The `ddd` profile vendors the exact `io.github.fuzhengwei:ddd-scaffold-lite-jdk17:1.7`
archetype resources under `profiles/ddd/xfg-archetype`, and generated projects
receive the same reference under `docs/reference/xfg-ddd-scaffold-lite-jdk17`.

## Profile Selection

Use `agent-adapters` for AI tool compatibility in most projects. Add stack or
domain profiles only when they apply:

| Profile | Use When |
| --- | --- |
| `core` | Always installed. Provides state, task cards, guards, Plan Engine, hooks, and closeout. |
| `agent-adapters` | The project will be used by Codex, Claude Code, Superpowers, Cursor, Cline, Roo, Windsurf, Gemini, or GitHub Copilot. |
| `api-contract` | API behavior should be designed before implementation and kept in `docs/API_SPEC.md`. |
| `ddd` | The project follows the Xiao Fu Ge DDD scaffold baseline. |
| `java-spring` | Java/Spring commands and architecture checks are needed. |
| `vue` | Vue/frontend commands and style checks are needed. |
| `finance` | Financial safety, audit, permission, and mutation boundaries are needed. |

## Task Lifecycle

1. Create a task id such as `T-001`.
2. Write or update:
   - `docs/tasks/T-001.md`
   - `docs/specs/T-001-requirements.md`
   - `docs/designs/T-001-design.md`
   - `docs/plans/T-001-plan.md`
3. Validate:

```bash
bash scripts/spec-lint.sh T-001
```

4. Lock the plan:

```bash
bash scripts/plan-lock.sh T-001
```

5. Start the current step:

```bash
bash scripts/plan-step.sh T-001 S-001 --start
```

6. Implement only files allowed by `S-001`.
7. Commit the step:

```bash
git add .
git commit -m "T-001: implement current step"
```

8. Complete the step:

```bash
bash scripts/plan-step.sh T-001 S-001 --complete
```

9. Repeat for the next step until the plan enters closeout.
10. Run closeout:

```bash
bash scripts/drift-guard.sh
bash scripts/task-closeout.sh T-001 --write-report
```

## Handling Scope Changes

If the agent needs to change scope after the plan is locked, it must stop and
report:

```txt
PLAN_CHANGE_REQUIRED
reason:
requested_change:
affected_files:
suggested_plan_update:
```

Then update the requirements, design, task card, and plan together before
locking again.

## API Design Rule

When `api-contract` is enabled, design the API before implementation. Use
`docs/API_SPEC.md` as the source of truth for endpoints, request/response
shapes, errors, auth, idempotency, pagination, and compatibility.

Swagger/OpenAPI can be generated after implementation, but it should not be the
first source of truth for a new endpoint. If generated Swagger conflicts with
`docs/API_SPEC.md`, update one side intentionally and record the decision in the
task.

## Git Checkpoints

The template expects agents to report commit and push state:

- `COMMIT_CHECKPOINT`: a local commit exists for the task.
- `NO_COMMIT_CHECKPOINT`: no local task commit exists, with a reason.
- `PUSH_CHECKPOINT`: the branch was pushed.
- `NO_PUSH_CHECKPOINT`: push was not requested, not possible, or blocked.

`plan-step --complete` enforces local commit checkpoints when
`require_step_commit: true` or the current step declares `commit: required`.
Remote push is not automatic unless closeout is run with `--push` and the
repository is allowed to push the current branch.

## What This Prevents

- Implementing without an approved task and locked plan.
- Quietly changing a locked plan.
- Editing files outside the current step allowlist.
- Completing a step while uncommitted changes remain.
- Skipping drift guard and closeout reports.
- Treating a native AI plan as authoritative when it conflicts with repository
  files.

## What This Does Not Guarantee

- It does not prove the product decision is correct.
- It does not replace code review.
- It does not make tests exhaustive.
- It does not stop a tool that ignores shell command failures.
- It does not push to a remote unless credentials, branch policy, and user intent
  allow it.

The value is narrower and practical: make drift visible, block common unsafe
paths, and leave auditable evidence when a task is closed.
