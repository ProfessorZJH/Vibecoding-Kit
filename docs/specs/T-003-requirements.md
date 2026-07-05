# T-003 Requirements

status: approved

## Problem

Vibecoding Kit now has prompt, policy, guard, and report layers, but generated
projects do not yet include a reusable workflow layer that tells agents how to
operate those layers across the full task lifecycle. Adapter bridge documents
exist, but users still need a concise capability matrix that explains how Codex,
Claude Code, Gemini, Cursor, Cline, Roo, Windsurf, GitHub Copilot, and similar
tools interact with the kit.

## Goals

- Add workflow phase documents that guide agents through scan, task creation,
  plan lock, implementation, risk review, and closeout.
- Add an adapter capability matrix that documents supported tool entry files and
  enforcement limits.
- Update agent adapter entry files so installed projects point agents to the
  workflow layer.
- Update tests to verify workflow files are present, installed, and referenced.
- Update README to describe the workflow layer in the architecture.

## Non-Goals

- Do not add a CLI.
- Do not add managed adapter block synchronization.
- Do not parse YAML policies.
- Do not change guard behavior.
- Do not add a command executor, sandbox, or approval runner.
- Do not create a command-risk demo.

## Acceptance Criteria

- `core/workflows/README.md` exists.
- `core/workflows/project-scan.md`, `task-create.md`, `plan-lock.md`,
  `implement-step.md`, `risk-review.md`, and `closeout.md` exist.
- Every workflow document includes Purpose, Inputs, Read Order, Allowed Actions,
  Forbidden Actions, Commands, Expected Outputs, and Stop Conditions.
- `docs/adapter-capabilities.md` exists and documents the supported adapters.
- `profiles/agent-adapters/root/AGENTS.md`, `CLAUDE.md`, and `GEMINI.md`
  reference installed `workflows/`.
- Cursor, Cline, Roo, Windsurf, and GitHub Copilot adapter files reference
  installed `workflows/` when the existing file style allows it without
  over-expansion.
- `scripts/test-kit.sh` verifies core workflow files, installed workflow files,
  adapter references, and adapter capability docs.
- Existing `scripts/test-kit.sh` checks continue to pass.

## Risk

medium
