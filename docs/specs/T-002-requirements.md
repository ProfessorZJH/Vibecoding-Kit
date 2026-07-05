# T-002 Requirements

status: approved

## Problem

Vibecoding Kit already enforces plan drift and closeout basics, but it still
represents path boundaries mostly inside prompts or shell logic, has no
dedicated command classification guard, and produces no standalone file-change
risk report. That leaves command safety and review evidence weaker than the
plan-engine layer.

## Goals

- Add a documented policy layer for paths, commands, and risk levels.
- Add `command-guard.sh` with `allow`, `require_approval`, and `block`
  decisions.
- Add `risk-report.sh` that writes markdown and JSON artifacts for the current
  task.
- Integrate risk reporting into `drift-guard.sh` and `task-closeout.sh`.
- Extend tests and release/docs coverage for the new governance layer.

## Non-Goals

- Do not create a second implementation workflow under `docs/superpowers/**`.
- Do not make shell scripts parse YAML policy files in v1.
- Do not build a command executor or approval runner.
- Do not make HIGH or CRITICAL risk classification block drift or closeout by
  itself in v1.
- Do not add a new demo in this task.

## Acceptance Criteria

- `core/docs/policies/path-policy.yml` exists and documents sensitive paths and
  generated/local artifact paths.
- `core/docs/policies/command-policy.yml` exists and documents allow,
  require-approval, and block command classes.
- `core/docs/policies/risk-policy.yml` exists and documents LOW, MEDIUM, HIGH,
  and CRITICAL file-path risk mappings.
- `core/scripts/command-guard.sh` classifies safe, approval-required, and
  blocked commands with consistent output and exit behavior.
- `core/scripts/risk-report.sh` writes
  `reports/ai-risk/T-002-risk-report.md` and
  `reports/ai-risk/T-002-risk-report.json`.
- `core/scripts/drift-guard.sh` runs the risk report when task context is
  present and only fails when a real guard/runtime failure occurs.
- `core/scripts/task-closeout.sh` includes risk evidence in the generated
  closeout report.
- `scripts/test-kit.sh` covers the new governance layer.
- Existing prompt module and agent adapter installation tests continue to pass.
- README and `docs/releases/POLICY_COMMAND_RISK_MVP.md` describe the new layer
  and its limits accurately.

## Risk

medium
