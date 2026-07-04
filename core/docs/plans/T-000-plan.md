# T-000 Initialize Vibecoding OS Plan

status: locked

## S-001 Verify Initialized Kit

status: pending

allowed_changes:
- **

forbidden_changes:
- .env*
- target/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- bash scripts/spec-lint.sh T-000
- bash scripts/plan-guard.sh T-000 S-001
- bash scripts/drift-guard.sh
- bash scripts/task-closeout.sh T-000 --no-tests --write-report

expected:
- SPEC_LINT_PASS
- PLAN_GUARD_PASS
- DRIFT_GUARD_PASS
- CLOSEOUT

commit:
- required
