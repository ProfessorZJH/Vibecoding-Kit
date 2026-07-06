# Changelog

## v0.5.0 - Governance Demos and UX Polish

Added:

- Command risk demo.
- Risk report demo.
- Adapter block demo.
- Examples index.
- README demo matrix.
- test-kit coverage for all governance demos.

Unchanged:

- No new CLI.
- No guard semantic changes.
- No automatic adapter sync.
- No network-dependent demo execution.

## v0.3.0 - 2026-07-05

- Added reusable workflow documents for project scan, task creation, plan lock,
  step implementation, risk review, and closeout.
- Added an adapter capability matrix covering Codex, Claude Code, Gemini,
  Cursor, Cline, Roo, Windsurf, GitHub Copilot, and Superpowers.
- Routed adapter entry files and core agent instructions to the workflow layer.
- Extended kit tests to verify workflow installation and adapter references.

## v0.2.0 - 2026-07-05

- Added modular Vibecoding prompt modules and routed agent adapter entry files
  to the shared prompt layer.
- Added governance policy documents for paths, command classes, and file-change
  risk levels.
- Added `command-guard.sh`, `risk-report.sh`, and their drift/closeout
  integrations for repository-level AI agent governance evidence.
- Added release notes for the Governance MVP package.

## v0.1.0 - 2026-07-04

- Added a runnable AI drift demo that proves `plan-guard.sh` blocks an
  unauthorized file change.
- Added README demo output so new users can understand the project before
  reading the full handbook.
- Added GitHub Actions CI for `scripts/test-kit.sh`.
- Added release notes for the Plan Engine MVP and v0.1.0 demo packaging.

## Unreleased

- TypeScript CLI wrapper is planned after the demo and CI path are stable.
