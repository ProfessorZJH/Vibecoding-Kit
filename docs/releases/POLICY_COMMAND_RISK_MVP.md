# Policy, Command Guard, and Risk Report MVP

Release date: 2026-07-05

## Purpose

This release extends Vibecoding Kit from a prompt-and-plan-drift baseline into
an AI agent governance MVP with explicit policy files, command classification,
and risk evidence.

## Included Capabilities

- `docs/policies/path-policy.yml`: documents sensitive paths, generated/local
  artifacts, and protected system write paths.
- `docs/policies/command-policy.yml`: documents safe read-only commands,
  approval-required commands, and forbidden command patterns.
- `docs/policies/risk-policy.yml`: documents LOW, MEDIUM, HIGH, and CRITICAL
  file-path risk classes.
- `scripts/command-guard.sh`: classifies commands as `allow`,
  `require_approval`, or `block`.
- `scripts/risk-report.sh`: writes markdown and JSON risk evidence for the
  current task.
- `scripts/drift-guard.sh`: generates risk reports while skipping
  `command-guard.sh` as a non-auto-runnable classifier.
- `scripts/task-closeout.sh`: records risk evidence in closeout output and
  closeout reports.
- `scripts/test-kit.sh` and `scripts/test-ai-guards.sh`: verify policy
  installation, command classification, risk reporting, and closeout evidence.

## Installed Project Contract

Generated projects gain policy files under `docs/policies/` and new governance
commands:

```bash
bash scripts/command-guard.sh "git status"
bash scripts/command-guard.sh "npm install"
bash scripts/risk-report.sh T-xxx
bash scripts/drift-guard.sh
bash scripts/task-closeout.sh T-xxx --write-report
```

Expected command classification signals:

```txt
COMMAND_GUARD_PASS
decision: allow

COMMAND_GUARD_PASS
decision: require_approval

COMMAND_GUARD_FAIL
decision: block
```

## Limits

- Policy files are documentation-first in this MVP. Shell guards do not parse
  YAML policy files yet.
- HIGH or CRITICAL risk classification is reported, not used as a standalone
  blocker.
- `command-guard.sh` is a classifier, not a command runner or shell sandbox.
- Human review, semantic tests, and product judgment are still required.

## Verification

Run from this kit repository:

```bash
bash scripts/test-kit.sh
git diff --check
```
