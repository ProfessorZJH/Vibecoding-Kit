# Governance Demos and UX Polish Design

## Summary

T-005 adds three short demos and a demo index so reviewers can see Vibecoding
Kit's governance loop without reading every guard script. The demos cover
command classification, risk report evidence, and managed adapter block
preservation. They complement the existing AI drift demo.

## Scope

- Add `examples/command-risk-demo/`.
- Add `examples/risk-report-demo/`.
- Add `examples/adapter-block-demo/`.
- Add `examples/README.md`.
- Update root README with a Demos section.
- Add `docs/releases/v0.5.0.md`.
- Extend `scripts/test-kit.sh` so demos stay executable and honest.

## Non-Scope

- No CLI.
- No adapter sync.
- No global tool directory sync.
- No command execution or approval runner.
- No YAML parser.
- No changes to command, drift, risk, closeout, installer, or adapter block
  semantics.
- No risk-report blocking behavior.

## Chosen Approach

Use independent shell demos. Each demo owns one concept and prints stable
`DEMO_STEP` markers plus `DEMO_PASS`. The demos use existing source scripts and
temporary files or projects. This follows the current `ai-drift-demo` pattern
and keeps failures easy to diagnose.

The root README should show all demo commands together. `examples/README.md`
should provide a compact catalog. `scripts/test-kit.sh` should execute the new
demos and verify both README files reference them.

## Alternatives Considered

1. One combined governance demo.
   This is rejected for T-005 because a single long script would make failures
   harder to localize and would duplicate the existing AI drift demo.
2. Documentation-only examples.
   This is rejected because demos should be executable and covered by
   `scripts/test-kit.sh`.
3. Start adapter sync immediately.
   This is deferred to T-006. T-005 is about proving existing behavior to
   users, not adding new update machinery.

## Acceptance

The work is complete when all three new demos print `DEMO_PASS`, root README and
`examples/README.md` list all four demos, `docs/releases/v0.5.0.md` documents
the release boundary, and `bash scripts/test-kit.sh` passes.
