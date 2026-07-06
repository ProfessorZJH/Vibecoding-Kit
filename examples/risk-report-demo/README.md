# Risk Report Demo

This demo shows `risk-report.sh` recording risk evidence for a runtime
configuration change. Risk reports preserve evidence for review; this demo does
not make HIGH risk block by itself.

Scenario:

1. Create a temporary project with Vibecoding Kit installed.
2. Commit the generated baseline.
3. Modify `src/main/resources/application.yml`.
4. Run `scripts/risk-report.sh T-000`.
5. Verify the report marks the change as HIGH risk.

Run from the repository root:

```bash
bash examples/risk-report-demo/run-demo.sh
```

Key output:

```txt
DEMO_STEP runtime_config_changed
DEMO_STEP risk_report_written
overall_risk: HIGH
DEMO_PASS
```

The demo uses a temporary project and deletes it on exit.
