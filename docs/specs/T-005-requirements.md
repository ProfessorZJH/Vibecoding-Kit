# T-005 Requirements

status: approved

## Problem

Vibecoding Kit has several governance primitives, but the README currently
shows only the AI drift demo. A reviewer can see plan drift being blocked, but
must inspect scripts and tests to understand command classification, risk
report evidence, and managed adapter block preservation.

The project needs short demos that make those capabilities observable without
introducing new architecture.

## Goals

- Add a command risk demo that shows allow, require-approval, and block
  decisions from `command-guard.sh`.
- Add a risk report demo that shows runtime configuration changes being
  reported as HIGH risk evidence.
- Add an adapter block demo that shows kit-owned content replacement while
  preserving user-owned content outside managed markers.
- Add README and examples index entries so users can find all demos quickly.
- Add test-kit coverage so demo scripts and documentation links stay current.
- Document the v0.5.0 release boundary.

## Non-Goals

- Do not add a CLI.
- Do not add command execution or approval handling.
- Do not make risk reporting block task closeout solely because risk is HIGH or
  CRITICAL.
- Do not add adapter sync or automatic adapter updates.
- Do not read or write global AI tool directories.
- Do not change existing shell guard semantics.
- Do not require network access during demos.

## Acceptance Criteria

- `examples/command-risk-demo/run-demo.sh`:
  - runs from the repository root
  - calls `core/scripts/command-guard.sh`
  - prints `DEMO_STEP safe_readonly_command`
  - prints `decision: allow`
  - prints `DEMO_STEP approval_required_command`
  - prints `decision: require_approval`
  - prints `DEMO_STEP blocked_remote_script`
  - prints `decision: block`
  - exits 0 and prints `DEMO_PASS`
- `examples/risk-report-demo/run-demo.sh`:
  - creates a temporary target project
  - installs Vibecoding Kit into the target
  - changes `src/main/resources/application.yml`
  - runs `scripts/risk-report.sh T-000`
  - verifies `reports/ai-risk/T-000-risk-report.md`
  - prints `overall_risk: HIGH`
  - exits 0 and prints `DEMO_PASS`
- `examples/adapter-block-demo/run-demo.sh`:
  - creates temporary target and template adapter files
  - validates the target managed block
  - updates the target from the template managed block
  - verifies target prefix and suffix are preserved
  - verifies old managed content is removed
  - verifies new managed content appears
  - verifies template prefix and suffix are not copied
  - exits 0 and prints `DEMO_PASS`
- Each new demo directory has a README and `expected-output.txt`.
- `examples/README.md` lists `ai-drift-demo`, `command-risk-demo`,
  `risk-report-demo`, and `adapter-block-demo`.
- Root README lists all four demo commands in a Demos section.
- `scripts/test-kit.sh` verifies the new demo directories, expected output
  files, executable scripts, demo outputs, README references, and examples
  index references.

## Risk

low
