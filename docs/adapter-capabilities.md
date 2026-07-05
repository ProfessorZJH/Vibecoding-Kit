# Adapter Capability Matrix

Vibecoding Kit normalizes AI coding tools around repository files. Tool-native
plans, todos, chats, and modes are useful scratch state, but task cards, locked
plans, guards, and reports are the portable contract.

| Tool | Entry File | Prompt Modules | Workflows | Guards | Notes |
| --- | --- | --- | --- | --- | --- |
| Codex and generic agents | `AGENTS.md` | yes | yes | manual | Best fit for repository-first execution. |
| Claude Code | `CLAUDE.md` | yes | yes | manual or hooks | Native todos and sub-agents must sync back to task files. |
| Gemini CLI | `GEMINI.md` | yes | yes | manual | Native plans are scratch until written to repository files. |
| Cursor | `.cursor/rules/vibecoding.mdc` | partial | partial | manual | Rules should stay concise and point to workflow docs. |
| Cline | `.clinerules` | partial | partial | manual | Plan state must be reflected in task and plan files. |
| Roo | `.roo/rules/vibecoding.md` | partial | partial | manual | Modes are scratch state unless written back to the task card. |
| Windsurf | `.windsurfrules` | partial | partial | manual | Cascade plans must sync to repository files before edits. |
| GitHub Copilot | `.github/copilot-instructions.md` | partial | limited | CI or manual | Instruction-only; enforcement comes from scripts and CI. |
| Superpowers | `docs/ai/SUPERPOWERS_BRIDGE.md` | yes | yes | manual | Skills may shape work, but the kit task card controls scope. |

## Shared Contract

Every adapter should converge on the same repository-level flow:

```bash
bash scripts/ai-preflight.sh T-xxx
bash scripts/spec-lint.sh T-xxx
bash scripts/plan-lock.sh T-xxx
bash scripts/plan-step.sh T-xxx S-xxx --start
bash scripts/plan-guard.sh T-xxx S-xxx
bash scripts/drift-guard.sh
bash scripts/task-closeout.sh T-xxx --write-report
```

## Limits

- Adapter files guide agents; guard scripts enforce repository-visible checks.
- Some tools can read long workflow documents; others need concise entry files
  that point to `workflows/README.md`.
- CI can verify guard scripts, but local agents still need to run workflow
  commands before claiming completion.
