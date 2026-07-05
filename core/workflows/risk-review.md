# Risk Review Workflow

## Purpose

Classify command and file-change risk so reviewers have explicit evidence.

## Inputs

- Proposed shell command.
- Current task id.
- Changed tracked and untracked files.
- `docs/policies/command-policy.yml`
- `docs/policies/risk-policy.yml`

## Read Order

1. Read command and risk policy files.
2. Read the current task card.
3. Inspect changed files with Git.
4. Read risk report output when it exists.

## Allowed Actions

- Classify commands with `scripts/command-guard.sh`.
- Generate risk evidence with `scripts/risk-report.sh`.
- Report HIGH or CRITICAL classifications for review.
- Keep classification report-only unless another guard fails.

## Forbidden Actions

- Do not execute a command through `command-guard.sh`.
- Do not treat `require_approval` as command approval.
- Do not make HIGH or CRITICAL file risk a standalone blocker in v1.
- Do not suppress risk evidence from closeout.

## Commands

```bash
bash scripts/command-guard.sh "git status"
bash scripts/command-guard.sh "npm install"
bash scripts/risk-report.sh T-xxx
```

## Expected Outputs

- `COMMAND_GUARD_PASS` with `decision: allow`
- `COMMAND_GUARD_PASS` with `decision: require_approval`
- `COMMAND_GUARD_FAIL` with `decision: block`
- `RISK_REPORT_WRITTEN`
- `reports/ai-risk/T-xxx-risk-report.md`
- `reports/ai-risk/T-xxx-risk-report.json`

## Stop Conditions

- Command classification returns `decision: block`.
- Risk report generation fails.
- Review requires a plan update before implementation can continue.
