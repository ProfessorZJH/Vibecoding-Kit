# T-007 Generated Project Smoke Demo Plan

status: locked

## S-001 Add T-007 Source Of Truth

status: completed

allowed_changes:
- docs/tasks/T-007.md
- docs/specs/T-007-requirements.md
- docs/designs/T-007-design.md
- docs/plans/T-007-plan.md
- docs/superpowers/specs/2026-07-06-generated-project-smoke-demo-design.md

forbidden_changes:
- examples/**
- README.md
- scripts/test-kit.sh
- docs/releases/**
- CHANGELOG.md
- core/scripts/**
- installer/**
- profiles/**
- docs/policies/**
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- git diff --check

expected:
- T-007 task, requirements, design, plan, and superpowers spec exist
- source-of-truth documents generated project smoke demo scope and non-goals

commit:
- required

## S-002 Add Failing Generated Demo Coverage

status: pending

allowed_changes:
- scripts/test-kit.sh

forbidden_changes:
- docs/tasks/**
- docs/specs/**
- docs/designs/**
- docs/plans/**
- docs/superpowers/**
- examples/**
- README.md
- docs/releases/**
- CHANGELOG.md
- core/scripts/**
- installer/**
- profiles/**
- docs/policies/**
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- bash -n scripts/test-kit.sh
- bash scripts/test-kit.sh

expected:
- test-kit syntax check passes
- test-kit fails before implementation because the generated project demo
  directory, README reference, or examples index entry is missing

commit:
- required after implementation makes tests pass

## S-003 Add Generated Project Demo

status: pending

allowed_changes:
- examples/generated-project-demo/**
- examples/README.md

forbidden_changes:
- docs/tasks/**
- docs/specs/**
- docs/designs/**
- docs/plans/**
- docs/superpowers/**
- README.md
- scripts/test-kit.sh
- docs/releases/**
- CHANGELOG.md
- core/scripts/**
- installer/**
- profiles/**
- docs/policies/**
- examples/ai-drift-demo/**
- examples/command-risk-demo/**
- examples/risk-report-demo/**
- examples/adapter-block-demo/**
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- bash -n examples/generated-project-demo/run-demo.sh
- bash examples/generated-project-demo/run-demo.sh

expected:
- generated-project-demo prints generated_project_installed,
  generated_files_verified, preflight_passed, drift_and_risk_checked,
  commit_checkpoint_created, closeout_report_written, and DEMO_PASS markers
- examples/README.md lists all five demos

commit:
- required

## S-004 Wire README and v0.6.0 Release Notes

status: pending

allowed_changes:
- README.md
- docs/releases/v0.6.0.md
- CHANGELOG.md

forbidden_changes:
- docs/tasks/**
- docs/specs/**
- docs/designs/**
- docs/plans/**
- docs/superpowers/**
- examples/**
- scripts/test-kit.sh
- core/scripts/**
- installer/**
- profiles/**
- docs/policies/**
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- git diff --check

expected:
- README includes the generated project demo command
- v0.6.0 release note documents generated project smoke demo scope and limits
- CHANGELOG.md includes v0.6.0

commit:
- required

## S-005 Verify and Close Out T-007

status: pending

allowed_changes:
- docs/plans/T-007-plan.md
- docs/tasks/T-007.md

forbidden_changes:
- docs/specs/**
- docs/designs/**
- docs/superpowers/**
- examples/**
- README.md
- scripts/test-kit.sh
- docs/releases/**
- CHANGELOG.md
- core/scripts/**
- installer/**
- profiles/**
- docs/policies/**
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- git diff --check
- bash -n examples/*/run-demo.sh
- bash -n scripts/test-kit.sh
- bash examples/generated-project-demo/run-demo.sh
- bash scripts/test-kit.sh

expected:
- all T-007 steps are completed
- whitespace check passes
- shell syntax checks pass
- generated project demo passes
- KIT_TESTS_PASS

commit:
- required
