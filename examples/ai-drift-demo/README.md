# AI Drift Demo

This demo shows Vibecoding Kit blocking an AI-style out-of-plan edit.

Scenario:

1. A plan step is locked to allow only `OrderQueryService.java`.
2. The implementation also changes `src/main/resources/application.yml`.
3. `plan-guard.sh` rejects the change as an unauthorized file.
4. The task card and plan are updated intentionally, relocked, committed, and
   closed out.

Run from the repository root:

```bash
bash examples/ai-drift-demo/run-demo.sh
```

Key output:

```txt
DEMO_STEP unauthorized_change_blocked
PLAN_GUARD_FAIL: unauthorized file
src/main/resources/application.yml
DEMO_STEP relocked_after_plan_update
DEMO_STEP closeout_report_written
DEMO_PASS
```

The demo uses a temporary project and deletes it on exit.
