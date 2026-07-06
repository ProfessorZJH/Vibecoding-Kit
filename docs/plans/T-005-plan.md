# T-005 Governance Demos and UX Polish Plan

status: locked

## S-001 Add T-005 Source Of Truth

status: completed

allowed_changes:
- docs/tasks/T-005.md
- docs/specs/T-005-requirements.md
- docs/designs/T-005-design.md
- docs/plans/T-005-plan.md
- docs/superpowers/specs/2026-07-06-governance-demos-ux-polish-design.md

forbidden_changes:
- examples/**
- README.md
- scripts/test-kit.sh
- docs/releases/**
- core/scripts/**
- installer/**
- profiles/**
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
- T-005 task, requirements, design, plan, and superpowers spec exist
- source-of-truth documents lock demo scope and non-goals

commit:
- required

## S-002 Add Failing Demo Coverage

status: completed

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
- core/scripts/**
- installer/**
- profiles/**
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- bash scripts/test-kit.sh

expected:
- test-kit fails before implementation because new demo directories, README
  references, or examples index entries are missing

commit:
- required after implementation makes tests pass

## S-003 Add Command and Risk Report Demos

status: completed

allowed_changes:
- examples/command-risk-demo/**
- examples/risk-report-demo/**

forbidden_changes:
- docs/tasks/**
- docs/specs/**
- docs/designs/**
- docs/plans/**
- docs/superpowers/**
- examples/adapter-block-demo/**
- examples/README.md
- README.md
- scripts/test-kit.sh
- docs/releases/**
- core/scripts/**
- installer/**
- profiles/**
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- bash -n examples/command-risk-demo/run-demo.sh
- bash -n examples/risk-report-demo/run-demo.sh
- bash examples/command-risk-demo/run-demo.sh
- bash examples/risk-report-demo/run-demo.sh

expected:
- command-risk-demo prints safe, approval, blocked, and DEMO_PASS markers
- risk-report-demo prints runtime_config_changed, risk_report_written,
  overall_risk: HIGH, and DEMO_PASS markers

commit:
- required

## S-004 Add Adapter Block Demo and Examples Index

status: completed

allowed_changes:
- examples/adapter-block-demo/**
- examples/README.md

forbidden_changes:
- docs/tasks/**
- docs/specs/**
- docs/designs/**
- docs/plans/**
- docs/superpowers/**
- examples/command-risk-demo/**
- examples/risk-report-demo/**
- README.md
- scripts/test-kit.sh
- docs/releases/**
- core/scripts/**
- installer/**
- profiles/**
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- bash -n examples/adapter-block-demo/run-demo.sh
- bash examples/adapter-block-demo/run-demo.sh

expected:
- adapter-block-demo prints check_valid_block, update_managed_block,
  user_content_preserved, and DEMO_PASS markers
- examples/README.md lists all four demos

commit:
- required

## S-005 Wire README and v0.5.0 Release Notes

status: completed

allowed_changes:
- README.md
- docs/releases/v0.5.0.md

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
- README includes all four demo commands
- v0.5.0 release note documents demo and UX polish scope

commit:
- required

## S-006 Verify and Close Out T-005

status: completed

allowed_changes:
- docs/plans/T-005-plan.md
- docs/tasks/T-005.md

forbidden_changes:
- docs/specs/**
- docs/designs/**
- docs/superpowers/**
- examples/**
- README.md
- scripts/test-kit.sh
- docs/releases/**
- core/scripts/**
- installer/**
- profiles/**
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
- bash scripts/test-kit.sh

expected:
- all T-005 steps are completed
- whitespace check passes
- shell syntax checks pass
- KIT_TESTS_PASS

commit:
- required
