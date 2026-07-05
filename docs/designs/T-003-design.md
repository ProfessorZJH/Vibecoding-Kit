# T-003 Design

status: approved

## Architecture

T-003 adds a workflow layer between prompt guidance and policy/guard execution.
Prompt modules describe mode-specific behavior. Workflow documents describe the
portable task lifecycle: what an agent reads, what it may do, what commands it
runs, what output it expects, and when it must stop. Policy files define
boundaries, guards check those boundaries, and reports preserve evidence.

The installed-project architecture becomes:

```text
Prompt -> Workflow -> Policy -> Guard -> Report
```

The workflow layer is documentation-only in this task. It does not add runtime
logic or alter guard behavior. The installer already copies `core/` into the
target project, so `core/workflows/*.md` will be installed as `workflows/*.md`.

## Files

- `core/workflows/README.md`: workflow index and lifecycle overview.
- `core/workflows/project-scan.md`: read-only project/context discovery.
- `core/workflows/task-create.md`: task/spec/design/plan source-of-truth
  creation.
- `core/workflows/plan-lock.md`: plan validation and lock flow.
- `core/workflows/implement-step.md`: current-step implementation discipline.
- `core/workflows/risk-review.md`: command and file-change risk evidence flow.
- `core/workflows/closeout.md`: drift guard, closeout report, and checkpoint
  reporting.
- `docs/adapter-capabilities.md`: capability matrix for supported agent tools.
- `profiles/agent-adapters/root/*`: adapter entry files that point to installed
  `workflows/`.
- `profiles/agent-adapters/docs/ai/*`: bridge docs updated where useful.
- `README.md`: architecture and documentation links.
- `scripts/test-kit.sh`: installation and reference coverage.

## Workflow Document Contract

Each workflow document uses the same headings:

- Purpose
- Inputs
- Read Order
- Allowed Actions
- Forbidden Actions
- Commands
- Expected Outputs
- Stop Conditions

The headings make the files predictable for both humans and agents. They also
give `test-kit.sh` a simple structure to assert without parsing semantics.

## Adapter Capability Matrix

`docs/adapter-capabilities.md` records each supported tool, its entry file,
whether it can consume prompt modules, whether it can follow workflow docs, how
guards are invoked, and the main limitation. It should be descriptive rather
than promotional. The matrix clarifies that enforcement remains manual, hook, or
CI driven depending on the tool.

## Data Flow

1. Installed adapter entry files tell agents to read `workflows/README.md`.
2. The workflow index routes the agent to the task phase document.
3. The phase document points to prompt modules, task files, policy files, guard
   scripts, and report artifacts.
4. Guard and report scripts continue to provide the executable verification
   layer.

## Error Handling

- If a workflow document conflicts with a task card or locked plan, the task
  card and locked plan remain authoritative.
- If an agent needs to act outside the current workflow or plan, it must stop
  and request a plan update.
- If a tool cannot enforce a workflow automatically, the adapter capability
  matrix must say so explicitly.

## Testing

- Verify all `core/workflows/*.md` files exist.
- Verify installed target projects include `workflows/*.md`.
- Verify workflow files include the required headings.
- Verify adapter entry files reference `workflows/README.md`.
- Verify `docs/adapter-capabilities.md` exists and is installed with the
  `agent-adapters` profile when applicable.
- Run `bash scripts/test-kit.sh`.
