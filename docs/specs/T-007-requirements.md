# T-007 Requirements

status: approved

## Problem

The repository has executable demos for individual governance primitives, but a
new user still has to infer whether those primitives work after installation
into a generated target project.

The project needs one short smoke demo that starts from a clean target
directory, installs Vibecoding Kit, and runs the installed governance scripts
from inside the generated project.

## Goals

- Add a generated project smoke demo under `examples/generated-project-demo/`.
- Show that `installer/init.sh` creates the expected project governance files.
- Show that the generated project can run `scripts/ai-preflight.sh T-000`.
- Show that the generated project can run `scripts/drift-guard.sh`, including
  initial risk report generation.
- Show that closeout can write `reports/ai-closeout/T-000.md` after the demo
  commits the generated project snapshot.
- Add README and examples index entries so users can find the demo quickly.
- Add test-kit coverage so demo scripts and documentation links stay current.
- Document the v0.6.0 release boundary.

## Non-Goals

- Do not add a CLI.
- Do not change installer behavior.
- Do not change guard, risk, closeout, adapter block, or policy semantics.
- Do not create a real business application.
- Do not require network access.
- Do not sync or write global AI tool directories.
- Do not add adapter sync.
- Do not make HIGH or CRITICAL risk reports standalone blockers.

## Acceptance Criteria

- `examples/generated-project-demo/run-demo.sh`:
  - runs from the repository root
  - creates a temporary target project
  - calls `installer/init.sh` with a deterministic demo project name
  - verifies `docs/AI_STATE.yml`
  - verifies `scripts/ai-preflight.sh`
  - verifies `scripts/drift-guard.sh`
  - verifies `scripts/risk-report.sh`
  - verifies `scripts/task-closeout.sh`
  - runs `bash scripts/ai-preflight.sh T-000` inside the target
  - verifies `PRECHECK` and `current_task: T-000`
  - runs `bash scripts/drift-guard.sh` inside the target
  - verifies `DRIFT_GUARD_PASS`
  - verifies `reports/ai-risk/T-000-risk-report.md`
  - commits the generated project snapshot with a `T-000:` commit subject
  - runs `bash scripts/task-closeout.sh T-000 --no-tests --write-report`
    inside the target
  - verifies `CLOSEOUT`
  - verifies `plan_guard: PLAN_GUARD_PASS S-001`
  - verifies `reports/ai-closeout/T-000.md`
  - prints stable `DEMO_STEP` markers
  - exits 0 and prints `DEMO_PASS`
- The demo directory has a README and `expected-output.txt`.
- `examples/README.md` lists `generated-project-demo`.
- Root README lists `examples/generated-project-demo/run-demo.sh`.
- `scripts/test-kit.sh` verifies the new demo directory, expected output file,
  executable script, demo output, README reference, and examples index
  reference.

## Risk

low
