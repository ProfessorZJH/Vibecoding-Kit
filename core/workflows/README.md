# Vibecoding Workflows

Workflow documents describe how AI coding agents move through a governed task.
They sit between prompt modules and guard scripts:

```text
Prompt -> Workflow -> Policy -> Guard -> Report
```

Use the document that matches the current phase:

- `project-scan.md`: understand the repository without changing it.
- `task-create.md`: create task, requirements, design, and plan source files.
- `plan-lock.md`: validate and lock a plan before implementation.
- `implement-step.md`: implement only the active plan step.
- `risk-review.md`: classify command and file-change risk.
- `closeout.md`: run final guards, write evidence, and report checkpoints.

If a workflow document conflicts with the task card or locked plan, follow the
task card and locked plan.
