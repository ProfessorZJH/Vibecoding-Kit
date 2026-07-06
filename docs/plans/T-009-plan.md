# T-009 Release Quality Gate and Readability Plan

status: completed

## S-001 Add T-009 Source Of Truth

status: completed

allowed_changes:
- docs/tasks/T-009.md
- docs/plans/T-009-plan.md

forbidden_changes:
- installer/**
- core/scripts/**
- scripts/**
- README.md
- docs/releases/**
- CHANGELOG.md
- examples/**
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
- T-009 task and plan exist.
- Scope is limited to readability, release quality gates, and README
  verification wording.

commit:
- required

## S-002 Add Failing Readability Guard Coverage

status: completed

allowed_changes:
- scripts/test-kit.sh

forbidden_changes:
- docs/tasks/**
- docs/plans/**
- docs/releases/**
- README.md
- CHANGELOG.md
- installer/**
- core/scripts/**
- examples/**
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
- `scripts/test-kit.sh` expects `scripts/readability-guard.sh`.
- Test-kit fails before implementation because the guard script is missing.

commit:
- required after implementation makes tests pass

## S-003 Add Readability Guard

status: completed

allowed_changes:
- scripts/readability-guard.sh
- scripts/test-kit.sh

forbidden_changes:
- installer/**
- core/scripts/**
- README.md
- docs/releases/**
- CHANGELOG.md
- docs/tasks/T-007.md
- docs/tasks/T-008.md
- docs/plans/T-008-plan.md
- examples/**
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
- bash -n scripts/readability-guard.sh
- bash scripts/readability-guard.sh

expected:
- Guard checks the required minimum line counts.
- Guard rejects extreme long lines in key Markdown files.
- Guard runs `bash -n` for key shell files.
- Guard prints `READABILITY_GUARD_PASS` on success.

commit:
- required

## S-004 Reflow Markdown Presentation

status: completed

allowed_changes:
- README.md
- examples/README.md
- CHANGELOG.md
- docs/releases/v0.7.0.md
- docs/tasks/T-007.md
- docs/tasks/T-008.md
- docs/plans/T-008-plan.md
- docs/tasks/T-009.md
- docs/plans/T-009-plan.md

forbidden_changes:
- installer/**
- core/scripts/**
- scripts/**
- examples/*/run-demo.sh
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
- bash scripts/readability-guard.sh

expected:
- Markdown headings, lists, tables, and code blocks are readable in raw form.
- README `Verify The Kit` says test-kit includes demo regression, installer UX
  regression, and the readability guard.

commit:
- required

## S-005 Reflow Shell Presentation

status: completed

allowed_changes:
- installer/init.sh
- scripts/test-kit.sh
- scripts/readability-guard.sh
- examples/generated-project-demo/run-demo.sh

forbidden_changes:
- core/scripts/**
- profiles/**
- docs/policies/**
- examples/*/expected-output.txt
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- bash -n installer/init.sh
- bash -n scripts/test-kit.sh
- bash -n scripts/readability-guard.sh
- bash -n examples/generated-project-demo/run-demo.sh
- bash scripts/readability-guard.sh

expected:
- Shell files are grouped and wrapped for review.
- Shell behavior and demo output markers are unchanged.
- All syntax checks pass.

commit:
- required

## S-006 Verify and Close Out T-009

status: completed

allowed_changes:
- docs/tasks/T-009.md
- docs/plans/T-009-plan.md
- README.md
- examples/README.md
- CHANGELOG.md
- docs/releases/v0.7.0.md
- docs/tasks/T-007.md
- docs/tasks/T-008.md
- docs/plans/T-008-plan.md
- installer/init.sh
- scripts/test-kit.sh
- scripts/readability-guard.sh
- examples/generated-project-demo/run-demo.sh

forbidden_changes:
- core/scripts/command-guard.sh
- core/scripts/risk-report.sh
- core/scripts/adapter-block.sh
- core/scripts/drift-guard.sh
- core/scripts/task-closeout.sh
- profiles/**
- docs/policies/**
- examples/*/expected-output.txt
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
- bash -n scripts/test-kit.sh
- bash -n scripts/readability-guard.sh
- bash -n examples/generated-project-demo/run-demo.sh
- bash scripts/readability-guard.sh
- bash scripts/test-kit.sh
- wc -l README.md examples/README.md CHANGELOG.md installer/init.sh
- wc -l scripts/test-kit.sh docs/releases/v0.7.0.md

expected:
- Whitespace check passes.
- Shell syntax checks pass.
- Readability guard passes.
- KIT_TESTS_PASS.
- Required line-count gates are met.

commit:
- required
