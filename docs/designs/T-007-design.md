# T-007 Design

status: approved

## Architecture

T-007 adds one onboarding smoke demo on top of the existing examples layer:

```text
Prompt -> Workflow -> Policy -> Guard -> Report -> Adapter Update -> Examples -> Generated Project Smoke
```

The demo is passive. It does not add production behavior or change existing
scripts. It installs the kit into a temporary target project, runs the installed
scripts in that target, validates stable output markers, and exits with
`DEMO_PASS`.

## Demo Structure

The new demo follows the existing example shape:

```text
examples/generated-project-demo/
  README.md
  run-demo.sh
  expected-output.txt
```

`run-demo.sh` is the executable source of truth. `expected-output.txt` records
stable markers only, not temporary paths, git hints, timestamps, or generated
commit hashes.

## Demo Flow

The script creates a temporary directory and installs the kit:

```bash
bash installer/init.sh \
  --target "$TARGET" \
  --name generated-project-demo \
  --profile agent-adapters \
  --ci none
```

The `agent-adapters` profile is used because it makes a generated project look
like a real AI-agent target while still avoiding stack-specific business
scaffold files and network dependencies.

After installation, the script verifies the generated target contains:

- `docs/AI_STATE.yml`
- `docs/tasks/T-000.md`
- `docs/plans/T-000-plan.md`
- `scripts/ai-preflight.sh`
- `scripts/drift-guard.sh`
- `scripts/risk-report.sh`
- `scripts/task-closeout.sh`

Then it runs:

```bash
bash scripts/ai-preflight.sh T-000
bash scripts/drift-guard.sh
git add .
git commit -m "T-000: initialize generated project demo"
bash scripts/task-closeout.sh T-000 --no-tests --write-report
```

The commit is required because closeout reports commit checkpoint state. The
demo uses local git identity configuration for that one commit and never pushes.

## Stable Markers

The demo prints these stable markers:

- `DEMO_STEP generated_project_installed`
- `DEMO_STEP generated_files_verified`
- `DEMO_STEP preflight_passed`
- `DEMO_STEP drift_and_risk_checked`
- `DEMO_STEP commit_checkpoint_created`
- `DEMO_STEP closeout_report_written`
- `DEMO_PASS`

The script validates actual command output before printing each step marker.

## Documentation

README adds the generated project demo to the existing demo matrix.
`examples/README.md` adds the same demo to the examples catalog.
`docs/releases/v0.6.0.md` documents the release as generated project smoke
demo and onboarding proof, not new governance semantics.

## Error Handling

The demo fails fast on missing files, unexpected output, or missing reports. It
prints `DEMO_FAIL` messages to stderr for assertion failures. Temporary
directories are removed on exit. The script sets `init.defaultBranch=master`
for the generated target to avoid environment-dependent git hints and branch
names.

## Testing

`scripts/test-kit.sh` verifies:

- the generated project demo directory exists
- the README and expected output file exist
- `run-demo.sh` is executable
- root README references the demo command
- `examples/README.md` references the demo command
- the demo prints each stable marker and `DEMO_PASS`

## Limits

T-007 does not add a CLI, change installer behavior, add adapter sync, change
guard/risk/closeout semantics, create a real business application, or require
network access.
