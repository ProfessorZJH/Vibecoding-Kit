# Vibecoding Kit Examples

These examples show how to use the kit after it has been installed into a target
project.

## Generic CLI Or Library Project

Install:

```bash
bash installer/init.sh \
  --target /path/to/tooling-project \
  --name tooling-project \
  --profile agent-adapters \
  --ci github
```

Typical task:

```bash
bash scripts/ai-preflight.sh T-001
bash scripts/spec-lint.sh T-001
bash scripts/plan-lock.sh T-001
bash scripts/plan-step.sh T-001 S-001 --start
```

Tell the AI agent to keep its native todo list synchronized with
`docs/plans/T-001-plan.md`, but to treat the repository plan as the source of
truth.

## Java/Spring + Vue + DDD Project

Install:

```bash
bash installer/init.sh \
  --target /path/to/app \
  --name demo-app \
  --profile java-spring \
  --profile vue \
  --profile ddd \
  --profile api-contract \
  --profile agent-adapters \
  --ci gitcode \
  --ci github
```

For API work, update `docs/API_SPEC.md` before controller, DTO, frontend client,
or Swagger changes. Use the plan step allowlist to separate contract, backend,
frontend, and verification work.

Example step split:

```md
## S-001 API Contract

allowed_changes:
- docs/API_SPEC.md
- docs/tasks/T-001.md
- docs/specs/T-001-requirements.md
- docs/designs/T-001-design.md
- docs/plans/T-001-plan.md

## S-002 Backend Endpoint

allowed_changes:
- "*-api/**"
- "*-trigger/**"
- "*-domain/**"
- "*-infrastructure/**"
- docs/AI_STATE.yml

## S-003 Frontend Integration

allowed_changes:
- web/**
- frontend/**
- docs/AI_STATE.yml
```

## Finance Project

Install:

```bash
bash installer/init.sh \
  --target /path/to/finance-app \
  --name finance-app \
  --profile java-spring \
  --profile vue \
  --profile ddd \
  --profile finance \
  --profile api-contract \
  --profile agent-adapters \
  --ci gitcode
```

Use the finance profile when AI must not silently mutate financial state. The
generated docs require permission, audit, validation, and explicit status
transitions for sensitive financial actions.

## Scope Change During Implementation

If the agent discovers that the current step needs files outside the allowlist,
it should not keep editing. It should stop with:

```txt
PLAN_CHANGE_REQUIRED
reason: S-002 needs a new migration file
requested_change: add db/migrations/20260704_add_invoice_status.sql
affected_files:
- docs/plans/T-001-plan.md
- db/migrations/20260704_add_invoice_status.sql
suggested_plan_update: add the migration path to S-002 allowed_changes
```

Then revise and relock the plan before continuing.

## Closeout With Push

Local closeout:

```bash
bash scripts/drift-guard.sh
bash scripts/task-closeout.sh T-001 --write-report
```

Closeout that also pushes the current branch:

```bash
bash scripts/task-closeout.sh T-001 --write-report --push
```

Protected `main` or `master` pushes require explicit `--allow-main-push`.
