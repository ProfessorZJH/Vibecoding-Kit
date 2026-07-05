# Agent Compatibility

The kit works by normalizing every tool into the same file protocol.
Use `docs/adapter-capabilities.md` for the full capability matrix and
`workflows/README.md` for the phase workflow index.

| Tool | Entry File | Rule |
| --- | --- | --- |
| Codex and generic agents | `AGENTS.md` | Read task card, run preflight, guard, closeout |
| Claude Code | `CLAUDE.md` | Native todos are scratch work until reflected in task card |
| Gemini CLI | `GEMINI.md` | Native plans must be written back to task card |
| Cursor | `.cursor/rules/vibecoding.mdc` | Composer plans must sync to task card |
| Windsurf | `.windsurfrules` | Plans must sync to task card |
| Cline | `.clinerules` | Plans must sync to task card |
| Roo | `.roo/rules/vibecoding.md` | Modes must obey task card |
| GitHub Copilot | `.github/copilot-instructions.md` | Chat plans must sync to task card |
| Superpowers | `docs/ai/SUPERPOWERS_BRIDGE.md` | Skills may plan, but task card controls execution |

## Non-Negotiable Contract

Every tool must converge on:

```bash
bash scripts/ai-preflight.sh T-xxx
bash scripts/drift-guard.sh
bash scripts/task-closeout.sh T-xxx --write-report
```
