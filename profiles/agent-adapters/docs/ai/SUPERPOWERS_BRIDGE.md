# Superpowers Bridge

Superpowers skills are compatible with this kit when their outputs are written
back to the project protocol.

## Mapping

| Superpowers Output | Vibecoding Destination |
| --- | --- |
| Brainstorming design | `docs/tasks/T-xxx.md` background and required work |
| Written plan | `docs/tasks/T-xxx.md` required work and test requirements |
| Todo tracking | Native scratch state only |
| Verification | `scripts/drift-guard.sh` and `scripts/task-closeout.sh` |

## Rule

Use Superpowers for thinking and task execution discipline, but do not let a
Superpowers plan replace the task card. Before implementation, the actionable
scope must exist in `docs/tasks/T-xxx.md`.
Use `workflows/README.md` to map Superpowers activity to the current
Vibecoding phase.

Before implementation, convert the tool's native plan into the locked plan engine contract.
Native todos, modes, and plan panes are scratch state; the portable contract is
`docs/plans/T-xxx-plan.md` plus `docs/AI_STATE.yml`.
