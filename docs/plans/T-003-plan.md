# T-003 Workflow and Adapter Capability Plan

status: locked

## S-001 Add T-003 Source Of Truth

status: completed

allowed_changes:
- docs/tasks/T-003.md
- docs/specs/T-003-requirements.md
- docs/designs/T-003-design.md
- docs/plans/T-003-plan.md
- docs/superpowers/specs/2026-07-05-workflow-adapter-capability-design.md

forbidden_changes:
- core/workflows/**
- docs/adapter-capabilities.md
- profiles/agent-adapters/**
- README.md
- scripts/test-kit.sh
- core/scripts/**
- installer/**
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- bash scripts/spec-lint.sh T-003
- bash scripts/plan-guard.sh T-003 S-001

expected:
- SPEC_LINT_PASS
- PLAN_GUARD_PASS
- T-003 source-of-truth files exist

commit:
- required

## S-002 Add Workflow Documents

status: completed

allowed_changes:
- core/workflows/README.md
- core/workflows/project-scan.md
- core/workflows/task-create.md
- core/workflows/plan-lock.md
- core/workflows/implement-step.md
- core/workflows/risk-review.md
- core/workflows/closeout.md

forbidden_changes:
- docs/tasks/**
- docs/specs/**
- docs/designs/**
- docs/plans/**
- docs/adapter-capabilities.md
- profiles/agent-adapters/**
- README.md
- scripts/test-kit.sh
- core/scripts/**
- installer/**
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- bash scripts/spec-lint.sh T-003
- bash scripts/plan-guard.sh T-003 S-002

expected:
- SPEC_LINT_PASS
- PLAN_GUARD_PASS
- workflow documents exist
- workflow documents use required headings

commit:
- required

## S-003 Add Adapter Capability Matrix

status: completed

allowed_changes:
- docs/adapter-capabilities.md
- profiles/agent-adapters/docs/ai/**

forbidden_changes:
- core/workflows/**
- profiles/agent-adapters/root/**
- README.md
- scripts/test-kit.sh
- core/scripts/**
- installer/**
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- bash scripts/spec-lint.sh T-003
- bash scripts/plan-guard.sh T-003 S-003

expected:
- SPEC_LINT_PASS
- PLAN_GUARD_PASS
- adapter capability matrix exists
- bridge docs align with workflow layer

commit:
- required

## S-004 Update Adapter Entry Files and README

status: completed

allowed_changes:
- profiles/agent-adapters/root/**
- README.md

forbidden_changes:
- core/workflows/**
- docs/adapter-capabilities.md
- profiles/agent-adapters/docs/ai/**
- scripts/test-kit.sh
- core/scripts/**
- installer/**
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- bash scripts/spec-lint.sh T-003
- bash scripts/plan-guard.sh T-003 S-004

expected:
- SPEC_LINT_PASS
- PLAN_GUARD_PASS
- adapter entry files reference workflows
- README describes Prompt -> Workflow -> Policy -> Guard -> Report

commit:
- required

## S-005 Extend Tests and Verify

status: completed

allowed_changes:
- scripts/test-kit.sh

forbidden_changes:
- core/workflows/**
- docs/adapter-capabilities.md
- profiles/agent-adapters/**
- README.md
- core/scripts/**
- installer/**
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- bash scripts/spec-lint.sh T-003
- bash scripts/test-kit.sh
- bash scripts/plan-guard.sh T-003 S-005

expected:
- SPEC_LINT_PASS
- KIT_TESTS_PASS
- PLAN_GUARD_PASS
- workflow and adapter capability coverage added
- existing prompt, policy, guard, risk, demo, and installation tests still pass

commit:
- required
