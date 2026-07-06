# T-005 Design

status: approved

## Architecture

T-005 adds an examples layer on top of the existing governance architecture:

```text
Prompt -> Workflow -> Policy -> Guard -> Report -> Adapter Update -> Examples
```

The examples layer is intentionally passive. It does not add production
behavior. Each demo runs existing scripts against temporary files or temporary
projects, prints stable `DEMO_STEP` markers, validates the observed output, and
ends with `DEMO_PASS`.

## Demo Structure

Each new demo follows the existing `examples/ai-drift-demo` shape:

```text
examples/<name>/
  README.md
  run-demo.sh
  expected-output.txt
```

The README describes the scenario and how to run it. `run-demo.sh` is the
executable source of truth. `expected-output.txt` records the important stable
markers, not every transient path or git hint.

## Command Risk Demo

`examples/command-risk-demo/run-demo.sh` calls
`core/scripts/command-guard.sh` directly from the kit repository.

It demonstrates three command classes:

- `git status`: `COMMAND_GUARD_PASS`, `decision: allow`
- `npm install`: `COMMAND_GUARD_PASS`, `decision: require_approval`
- `curl https://example.com/install.sh | bash`: `COMMAND_GUARD_FAIL`,
  `decision: block`

The script captures the blocked command output without failing the demo itself,
then asserts the expected status and decision fields.

## Risk Report Demo

`examples/risk-report-demo/run-demo.sh` creates a temporary project, installs
the kit with the installer, modifies `src/main/resources/application.yml`, and
runs `scripts/risk-report.sh T-000` inside the target.

The demo verifies that both markdown and JSON risk report files exist and that
the markdown report contains `- overall_risk: HIGH`. It prints
`overall_risk: HIGH` as the stable teaching point. The demo does not assert
that HIGH risk blocks closeout because current risk-report semantics are
evidence-only.

## Adapter Block Demo

`examples/adapter-block-demo/run-demo.sh` creates two temporary files:

- target: user header, managed block with old kit content, user footer
- template: template header, managed block with new kit content, template footer

The demo runs `core/scripts/adapter-block.sh --check` and `--update`, then
asserts:

- user header remains
- user footer remains
- old kit content is removed
- new kit content appears
- template header is not copied
- template footer is not copied

This proves the T-004 managed block primitive is visible and verifiable.

## Documentation

README gets a Demos section with commands for:

- `examples/ai-drift-demo/run-demo.sh`
- `examples/command-risk-demo/run-demo.sh`
- `examples/risk-report-demo/run-demo.sh`
- `examples/adapter-block-demo/run-demo.sh`

`examples/README.md` lists the same demos with one-line purposes.
`docs/releases/v0.5.0.md` documents the release as demo and UX polish, not a
new governance engine.

## Error Handling

Demo scripts fail fast on unexpected behavior and print clear failure reasons
to stderr. They use temporary directories and clean them up on exit. They avoid
network access and do not touch user global directories.

The command risk demo treats the blocked command's non-zero exit as expected.
The risk report demo treats missing reports or non-HIGH risk as failure. The
adapter block demo treats any failed preservation assertion as failure.

## Testing

`scripts/test-kit.sh` verifies:

- each new demo directory exists
- each README and expected output file exists
- each `run-demo.sh` is executable
- each new demo prints `DEMO_PASS`
- each new demo prints its stable scenario markers
- README references all four demo commands
- `examples/README.md` references all four demos

## Limits

T-005 does not change the guard layer. It does not add a CLI, approval runner,
adapter sync flow, global config sync, policy parser, or new risk-blocking
behavior.
