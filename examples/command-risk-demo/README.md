# Command Risk Demo

This demo shows `command-guard.sh` classifying commands without executing the
commands themselves.

Scenario:

1. A read-only command is allowed.
2. A dependency install requires approval.
3. A remote script execution command is blocked.

Run from the repository root:

```bash
bash examples/command-risk-demo/run-demo.sh
```

Key output:

```txt
DEMO_STEP safe_readonly_command
decision: allow
DEMO_STEP approval_required_command
decision: require_approval
DEMO_STEP blocked_remote_script
decision: block
DEMO_PASS
```
