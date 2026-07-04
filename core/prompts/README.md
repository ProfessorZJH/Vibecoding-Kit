# Vibecoding Kit Prompts

This directory contains prompt modules for AI coding agents working inside
repositories governed by Vibecoding Kit.

These prompts are designed for Vibecoding Kit's repository-first workflow:

- file-based memory
- task cards
- plan lock
- current step enforcement
- guard scripts
- Git checkpoints
- closeout reports
- CI verification

Prompt instructions are soft constraints. Guard scripts are hard constraints.

## Prompt Modules

| File | Purpose |
| --- | --- |
| `00-agent-contract.md` | Global behavior contract for AI agents |
| `01-explore-readonly.md` | Read-only repository exploration |
| `02-plan-locked-task.md` | Guard-checkable implementation planning |
| `03-implement-current-step.md` | Scope-limited current-step implementation |
| `04-command-classifier.md` | Bash command prefix, injection, and risk classification |
| `05-security-review.md` | High-confidence security review of the current task diff |
| `06-closeout-report.md` | Task closeout verification and reporting |
| `07-task-memory-summary.md` | Context preservation across long sessions or compaction |

## Recommended Agent Flow

```text
Explore Mode
  -> read source of truth
  -> inspect relevant files
  -> produce exploration report

Plan Mode
  -> create step-level plan
  -> define allowed changes
  -> define forbidden changes
  -> define required tests
  -> lock plan

Implement Mode
  -> verify current task and step
  -> edit only allowed files
  -> run tests
  -> run guards

Closeout Mode
  -> summarize changes
  -> verify scope
  -> report tests and guards
  -> record unresolved risks
```

## Installed Path

In this kit repository, prompt modules live under:

```text
core/prompts/
```

After `installer/init.sh` copies `core` into a target project, prompt modules
live under:

```text
prompts/
```

Agent adapter files such as `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`,
Cursor/Cline/Roo/Windsurf rules, and GitHub Copilot instructions should
reference the installed `prompts/` path.
