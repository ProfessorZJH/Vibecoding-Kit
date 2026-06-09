# AI Rules Index

This file is the short index for AI agents. Full rules live in the referenced
documents and selected profiles.

## Required Startup

```bash
bash scripts/ai-preflight.sh T-xxx
```

## Plan Engine

When `require_plan_guard: true`, implementation requires:

```bash
bash scripts/spec-lint.sh T-xxx
bash scripts/plan-guard.sh T-xxx S-xxx
```

Plan changes require:

```txt
PLAN_CHANGE_REQUIRED
reason:
requested_change:
affected_files:
suggested_plan_update:
```

## Required Closeout

```bash
bash scripts/drift-guard.sh
bash scripts/task-closeout.sh T-xxx
```

To write a closeout report:

```bash
bash scripts/task-closeout.sh T-xxx --write-report
```

## Completion States

- `COMMIT_CHECKPOINT`: local commit exists.
- `PUSH_CHECKPOINT`: remote branch push exists.
- `NO_COMMIT_CHECKPOINT`: commit could not be made, with reason.
- `NO_PUSH_CHECKPOINT`: push could not be made or was not requested.

## P0 Rules

| Rule | Verification |
| --- | --- |
| Current task must be known | `scripts/ai-preflight.sh` |
| Unauthorized files are blocked | `scripts/task-closeout.sh` |
| Sensitive files and local artifacts are blocked | `scripts/task-closeout.sh` |
| Guard failures block completion | `scripts/drift-guard.sh` |

## Selected Profiles

Profile-specific docs and scripts may add stricter rules.
