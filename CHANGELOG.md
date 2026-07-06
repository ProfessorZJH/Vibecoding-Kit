# Changelog

## v0.7.0 - Installer UX Hardening

Added:

- Installer dry-run mode with stable create, skip, and conflict output.
- Installed generated-project doctor script at `scripts/ai-doctor.sh`.
- Repeat install safety for identical files and user-modified conflicts.
- test-kit coverage for dry-run, doctor, repeat install, and conflict
  preservation.
- README installer verification commands.
- v0.7.0 release notes.

Unchanged:

- No new CLI.
- No YAML parser.
- No guard semantic changes.
- No risk report blocking semantic changes.
- No automatic adapter sync.
- No network-dependent installer behavior.

## v0.6.0 - Generated Project Smoke Demo

Added:

- Generated project smoke demo.
- Generated project expected-output contract.
- README demo matrix entry for generated project onboarding.
- Examples index entry for the generated project demo.
- test-kit coverage for generated project demo execution and documentation
  references.
- v0.6.0 release notes.

Unchanged:

- No new CLI.
- No installer semantic changes.
- No guard semantic changes.
- No automatic adapter sync.
- No network-dependent demo execution.

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
