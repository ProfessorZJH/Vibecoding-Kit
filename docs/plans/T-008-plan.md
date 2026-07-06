# T-008 Installer UX Hardening Plan

status: locked

## S-001 Add T-008 Source Of Truth

status: completed

allowed_changes:
- docs/tasks/T-008.md
- docs/specs/T-008-requirements.md
- docs/designs/T-008-design.md
- docs/plans/T-008-plan.md
- docs/superpowers/specs/2026-07-06-installer-ux-hardening-design.md

forbidden_changes:
- installer/**
- core/scripts/**
- scripts/test-kit.sh
- README.md
- docs/releases/**
- CHANGELOG.md
- profiles/**
- examples/**
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
- T-008 task, requirements, design, plan, and superpowers spec exist
- source-of-truth documents installer UX scope and non-goals

commit:
- required

## S-002 Add Failing Installer UX Coverage

status: pending

allowed_changes:
- scripts/test-kit.sh

forbidden_changes:
- docs/tasks/**
- docs/specs/**
- docs/designs/**
- docs/plans/**
- docs/superpowers/**
- installer/**
- core/scripts/**
- README.md
- docs/releases/**
- CHANGELOG.md
- profiles/**
- examples/**
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
- test-kit fails before implementation because dry-run, ai-doctor, or reinstall
  safety behavior is missing

commit:
- required after implementation makes tests pass

## S-003 Implement Dry-Run and Safe Merge

status: pending

allowed_changes:
- installer/init.sh

forbidden_changes:
- docs/tasks/**
- docs/specs/**
- docs/designs/**
- docs/plans/**
- docs/superpowers/**
- core/scripts/**
- scripts/test-kit.sh
- README.md
- docs/releases/**
- CHANGELOG.md
- profiles/**
- examples/**
- docs/policies/**
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- bash -n installer/init.sh
- bash installer/init.sh --dry-run --target /tmp/vibecoding-kit-dry-run --name dry-run-demo --profile agent-adapters --ci none

expected:
- dry-run prints VIBECODING_KIT_DRY_RUN and DRY_RUN_PASS
- dry-run does not create target
- normal install preserves first-install profile overlay behavior
- repeat install skips identical files and conflicts on changed existing files

commit:
- required

## S-004 Add Installed Doctor

status: pending

allowed_changes:
- core/scripts/ai-doctor.sh

forbidden_changes:
- docs/tasks/**
- docs/specs/**
- docs/designs/**
- docs/plans/**
- docs/superpowers/**
- installer/**
- scripts/test-kit.sh
- README.md
- docs/releases/**
- CHANGELOG.md
- profiles/**
- examples/**
- docs/policies/**
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- bash -n core/scripts/ai-doctor.sh

expected:
- ai-doctor checks generated project core files and executable scripts
- ai-doctor prints DOCTOR_PASS on a healthy generated target

commit:
- required

## S-005 Wire README and v0.7.0 Release Notes

status: pending

allowed_changes:
- README.md
- docs/releases/v0.7.0.md
- CHANGELOG.md

forbidden_changes:
- docs/tasks/**
- docs/specs/**
- docs/designs/**
- docs/plans/**
- docs/superpowers/**
- installer/**
- core/scripts/**
- scripts/test-kit.sh
- profiles/**
- examples/**
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
- README documents installer dry-run and ai-doctor commands
- v0.7.0 release note documents installer UX hardening scope and limits
- CHANGELOG.md includes v0.7.0

commit:
- required

## S-006 Verify and Close Out T-008

status: pending

allowed_changes:
- docs/plans/T-008-plan.md
- docs/tasks/T-008.md

forbidden_changes:
- docs/specs/**
- docs/designs/**
- docs/superpowers/**
- installer/**
- core/scripts/**
- scripts/test-kit.sh
- README.md
- docs/releases/**
- CHANGELOG.md
- profiles/**
- examples/**
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
- bash -n installer/init.sh
- bash -n core/scripts/ai-doctor.sh
- bash -n scripts/test-kit.sh
- bash installer/init.sh --dry-run --target /tmp/vibecoding-kit-dry-run --name dry-run-demo --profile agent-adapters --ci none
- bash scripts/test-kit.sh

expected:
- all T-008 steps are completed
- whitespace check passes
- shell syntax checks pass
- dry-run passes
- KIT_TESTS_PASS

commit:
- required
