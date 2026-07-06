# T-008 Requirements

status: approved

## Problem

The installer can create a working target project, but it currently behaves like
a direct copy operation. A first-time user cannot preview the file plan, a
generated project has no single health-check command, and rerunning the
installer can overwrite existing files.

The project needs installer UX hardening that improves trust and repeatability
without turning the kit into a larger platform.

## Goals

- Add installer dry-run output.
- Add an installed doctor script for generated target projects.
- Make repeat installation preserve user-owned changes.
- Add test-kit coverage for dry-run, doctor, and repeat-install safety.
- Document installer verification commands in README and release notes.

## Non-Goals

- Do not add a CLI beyond shell flags and scripts.
- Do not add a YAML parser.
- Do not add automatic uninstall or rollback.
- Do not add global AI tool directory sync.
- Do not change guard, risk, closeout, adapter block, or policy semantics.
- Do not introduce network dependencies.
- Do not publish packages.

## Acceptance Criteria

- `bash installer/init.sh --dry-run --target "$target" --name dry-run-demo
  --profile agent-adapters --ci none`:
  - exits 0
  - prints `VIBECODING_KIT_DRY_RUN`
  - prints the target path
  - prints `project: dry-run-demo`
  - prints `profiles: agent-adapters`
  - prints `ci: none`
  - prints `will_create:`
  - prints `docs/AI_STATE.yml`
  - prints `scripts/ai-preflight.sh`
  - prints `scripts/ai-doctor.sh`
  - prints `DRY_RUN_PASS`
  - does not create the target directory when it did not already exist
- A normal install writes executable `scripts/ai-doctor.sh`.
- `bash scripts/ai-doctor.sh` inside a generated target:
  - exits 0
  - prints `DOCTOR`
  - prints `docs/AI_STATE.yml: ok`
  - prints `scripts/ai-preflight.sh: executable`
  - prints `scripts/drift-guard.sh: executable`
  - prints `scripts/task-closeout.sh: executable`
  - prints `DOCTOR_PASS`
- Repeat install safety:
  - If a target file exists with identical content, installer reports it as
    skipped and leaves it unchanged.
  - If a target file exists with different content, installer reports an
    install conflict and leaves it unchanged.
  - The installer exits non-zero when conflicts are found.
  - User-modified content in a conflicting file is preserved byte-for-byte.
- `scripts/test-kit.sh` covers dry-run, doctor, and repeat-install safety.

## Risk

medium
