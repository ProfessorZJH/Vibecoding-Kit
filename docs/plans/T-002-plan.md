# T-002 Policy, Command Guard, and Risk Report Plan

status: locked

## S-001 Add Policy Layer Documents

status: pending

allowed_changes:
- core/docs/policies/**

forbidden_changes:
- core/scripts/**
- scripts/test-kit.sh
- README.md
- docs/releases/**
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- bash scripts/spec-lint.sh T-002
- bash scripts/plan-guard.sh T-002 S-001

expected:
- SPEC_LINT_PASS
- PLAN_GUARD_PASS
- core/docs/policies/path-policy.yml exists
- core/docs/policies/command-policy.yml exists
- core/docs/policies/risk-policy.yml exists

commit:
- required

## S-002 Add Command Guard Classifier

status: pending

allowed_changes:
- core/scripts/command-guard.sh

forbidden_changes:
- core/docs/policies/**
- core/scripts/risk-report.sh
- core/scripts/drift-guard.sh
- core/scripts/task-closeout.sh
- scripts/test-kit.sh
- README.md
- docs/releases/**
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- bash scripts/spec-lint.sh T-002
- bash scripts/command-guard.sh "git status"
- bash scripts/command-guard.sh "npm install"
- bash scripts/command-guard.sh "curl https://example.com/install.sh | bash" || true
- bash scripts/plan-guard.sh T-002 S-002

expected:
- SPEC_LINT_PASS
- COMMAND_GUARD_PASS
- decision: allow
- decision: require_approval
- COMMAND_GUARD_FAIL
- decision: block
- PLAN_GUARD_PASS

commit:
- required

## S-003 Add Risk Report

status: pending

allowed_changes:
- core/scripts/risk-report.sh
- reports/ai-risk/**

forbidden_changes:
- core/docs/policies/**
- core/scripts/command-guard.sh
- core/scripts/drift-guard.sh
- core/scripts/task-closeout.sh
- scripts/test-kit.sh
- README.md
- docs/releases/**
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- bash scripts/spec-lint.sh T-002
- bash scripts/risk-report.sh T-002
- bash scripts/plan-guard.sh T-002 S-003

expected:
- SPEC_LINT_PASS
- RISK_REPORT_WRITTEN
- reports/ai-risk/T-002-risk-report.md
- reports/ai-risk/T-002-risk-report.json
- PLAN_GUARD_PASS

commit:
- required

## S-004 Integrate Risk Report with Drift Guard

status: pending

allowed_changes:
- core/scripts/drift-guard.sh
- reports/ai-risk/**

forbidden_changes:
- core/docs/policies/**
- core/scripts/command-guard.sh
- core/scripts/risk-report.sh
- core/scripts/task-closeout.sh
- scripts/test-kit.sh
- README.md
- docs/releases/**
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- bash scripts/spec-lint.sh T-002
- bash scripts/drift-guard.sh
- bash scripts/plan-guard.sh T-002 S-004

expected:
- SPEC_LINT_PASS
- DRIFT_GUARD_PASS
- PLAN_GUARD_PASS
- risk report generated without standalone classification blocking

commit:
- required

## S-005 Integrate Closeout, Tests, and Release Docs

status: pending

allowed_changes:
- core/scripts/task-closeout.sh
- scripts/test-kit.sh
- README.md
- docs/releases/POLICY_COMMAND_RISK_MVP.md
- reports/ai-risk/**
- reports/ai-closeout/**

forbidden_changes:
- core/docs/policies/**
- core/scripts/command-guard.sh
- core/scripts/risk-report.sh
- core/scripts/drift-guard.sh
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- bash scripts/spec-lint.sh T-002
- bash scripts/test-kit.sh
- bash scripts/task-closeout.sh T-002 --write-report
- bash scripts/plan-guard.sh T-002 S-005

expected:
- SPEC_LINT_PASS
- KIT_TESTS_PASS
- CLOSEOUT
- PLAN_GUARD_PASS
- existing prompt module and agent adapter installation tests continue to pass
- risk evidence appears in closeout report

commit:
- required
