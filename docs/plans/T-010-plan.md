# T-010 Java Service Governance Demo Plan

status: completed

## S-001 Add Failing Demo Coverage

status: completed

allowed_changes:
- scripts/test-kit.sh

forbidden_changes:
- core/scripts/**
- installer/**
- profiles/**
- docs/policies/**
- examples/java-service-governance-demo/**
- README.md
- examples/README.md
- docs/releases/**
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
- `scripts/test-kit.sh` expects the Java service governance demo files.
- Test-kit fails before implementation because the demo directory is missing.

commit:
- required after implementation makes tests pass

## S-002 Add Java Service Governance Demo

status: completed

allowed_changes:
- examples/java-service-governance-demo/**

forbidden_changes:
- core/scripts/**
- installer/**
- profiles/**
- docs/policies/**
- scripts/command-guard.sh
- scripts/risk-report.sh
- scripts/task-closeout.sh
- scripts/drift-guard.sh
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- bash -n examples/java-service-governance-demo/run-demo.sh
- bash examples/java-service-governance-demo/run-demo.sh

expected:
- Demo copies a Java/Spring-style fixture into a temporary Git repo.
- Demo simulates an allowed service-layer edit.
- Demo simulates an unauthorized runtime configuration edit.
- Plan guard detects `src/main/resources/application.yml`.
- Risk report prints `overall_risk: HIGH`.
- Closeout writes `reports/ai-closeout/T-010.md`.
- Demo ends with `DEMO_PASS`.

commit:
- required

## S-003 Wire Documentation and Release Notes

status: completed

allowed_changes:
- README.md
- examples/README.md
- docs/releases/v0.8.0.md
- docs/tasks/T-010.md
- docs/plans/T-010-plan.md

forbidden_changes:
- core/scripts/**
- installer/**
- profiles/**
- docs/policies/**
- scripts/command-guard.sh
- scripts/risk-report.sh
- scripts/task-closeout.sh
- scripts/drift-guard.sh
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
- README lists the Java service governance demo.
- Examples index lists the Java service governance demo.
- v0.8.0 release notes document demo scope and unchanged core semantics.

commit:
- required

## S-004 Verify and Close Out T-010

status: completed

allowed_changes:
- docs/tasks/T-010.md
- docs/plans/T-010-plan.md
- docs/releases/v0.8.0.md
- examples/java-service-governance-demo/**
- examples/README.md
- README.md
- scripts/test-kit.sh

forbidden_changes:
- core/scripts/**
- installer/**
- profiles/**
- docs/policies/**
- scripts/command-guard.sh
- scripts/risk-report.sh
- scripts/task-closeout.sh
- scripts/drift-guard.sh
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- git diff --check
- bash -n scripts/test-kit.sh
- bash -n scripts/readability-guard.sh
- bash -n examples/java-service-governance-demo/run-demo.sh
- bash examples/java-service-governance-demo/run-demo.sh
- bash scripts/readability-guard.sh
- bash scripts/test-kit.sh

expected:
- Whitespace check passes.
- Shell syntax checks pass.
- Java service demo passes.
- Readability guard passes.
- KIT_TESTS_PASS.

commit:
- required
