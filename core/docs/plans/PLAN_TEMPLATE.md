# T-xxx Plan

status: draft

## S-001 Step Name

status: pending

allowed_changes:
- path/**

forbidden_changes:
- .env*
- target/**
- node_modules/**

commands:
- bash scripts/drift-guard.sh

expected:
- DRIFT_GUARD_PASS

commit:
- required
