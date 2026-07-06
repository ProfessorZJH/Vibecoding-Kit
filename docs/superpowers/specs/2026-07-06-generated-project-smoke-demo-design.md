# Generated Project Smoke Demo Design

## Summary

T-007 adds one generated project smoke demo so reviewers can see Vibecoding Kit
go from repository template to working target project governance loop. The demo
installs the kit into a temporary target repository, verifies generated files,
runs preflight, drift/risk, and closeout inside that target, and ends with
`DEMO_PASS`.

## Scope

- Add `examples/generated-project-demo/`.
- Add the generated project demo to `examples/README.md`.
- Add the generated project demo to the root README demo matrix.
- Add `docs/releases/v0.6.0.md`.
- Extend `scripts/test-kit.sh` so the demo stays executable and documented.

## Non-Scope

- No CLI.
- No installer behavior changes.
- No guard, risk, closeout, policy, or adapter behavior changes.
- No adapter sync.
- No global AI tool directory sync.
- No business scaffold generation.
- No network-dependent demo behavior.

## Chosen Approach

Use one independent shell demo that follows the existing examples pattern. The
demo owns the generated-project onboarding story while the existing demos keep
covering individual governance primitives.

The demo installs with the `agent-adapters` profile and `--ci none` so the
target contains realistic agent entry files while staying small and offline.
It commits the generated project snapshot locally before closeout so
`task-closeout.sh` can report a commit checkpoint.

## Alternatives Considered

1. Extend `ai-drift-demo` to include generated project setup.
   This is rejected because AI drift and generated project onboarding are
   separate teaching points. Combining them would make failures harder to
   localize.
2. Add a large real-world stack demo.
   This is rejected for T-007 because the goal is smoke proof, not a Java/Vue or
   business scenario pack.
3. Change installer or closeout behavior to simplify the demo.
   This is rejected because T-007 must demonstrate current installed behavior,
   not introduce new semantics.

## Acceptance

The work is complete when `bash examples/generated-project-demo/run-demo.sh`
prints all stable `DEMO_STEP` markers and `DEMO_PASS`, README and
`examples/README.md` list all five demos, `docs/releases/v0.6.0.md` documents
the release boundary, and `bash scripts/test-kit.sh` passes.
