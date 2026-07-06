# Generated Project Demo

This demo shows Vibecoding Kit being installed into a clean target project and
then running the generated project's own governance scripts.

Scenario:

1. Create a temporary target project.
2. Install Vibecoding Kit with the `agent-adapters` profile.
3. Verify core generated files and scripts exist.
4. Run `scripts/ai-preflight.sh T-000` inside the target project.
5. Run `scripts/drift-guard.sh` inside the target project and verify the risk
   report exists.
6. Commit the generated project snapshot.
7. Run `scripts/task-closeout.sh T-000 --no-tests --write-report` and verify
   the closeout report exists.

Run from the repository root:

```bash
bash examples/generated-project-demo/run-demo.sh
```

Key output:

```txt
DEMO_STEP generated_project_installed
DEMO_STEP generated_files_verified
DEMO_STEP preflight_passed
DEMO_STEP drift_and_risk_checked
DEMO_STEP commit_checkpoint_created
DEMO_STEP closeout_report_written
DEMO_PASS
```

The demo uses a temporary project and deletes it on exit.
