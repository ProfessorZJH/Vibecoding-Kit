# AI Workflow Benchmark

date: 2026-06-08
scope: vibecoding-kit plan-engine design baseline

## Boundary

This benchmark does not claim to cover every workflow in the market. It covers a
fixed set of high-signal, mostly first-party sources and extracts mechanisms that
can be implemented as deterministic project files, scripts, hooks, or CI checks.

The goal is not "AI never makes mistakes". The goal is:

1. Make drift harder.
2. Detect drift earlier.
3. Block completion when drift occurs.
4. Record what happened.
5. Keep every agent converged on the same repository protocol.

## Sources Reviewed

| Source | Primary reference | Why it matters |
| --- | --- | --- |
| GitHub Spec Kit | https://github.github.com/spec-kit/ | Spec-driven lifecycle and agent-agnostic workflow framing |
| Kiro Specs | https://kiro.dev/docs/specs/ | Requirements/design/tasks separation and staged approval |
| OpenAI Codex exec plans | https://cookbook.openai.com/articles/codex_exec_plans | Long-running plan files, progress tracking, and human handoff |
| OpenAI Codex AGENTS.md | https://developers.openai.com/codex/guides/agents-md | Repository instructions as agent startup context |
| OpenAI Codex | https://developers.openai.com/codex/ | Cloud/CLI agent operating model, review, tasks, hooks, and environment control |
| Claude Code best practices | https://www.anthropic.com/engineering/claude-code-best-practices | CLAUDE.md, planning, permissions, automation, and multi-Claude workflows |
| Claude Code hooks | https://docs.anthropic.com/en/docs/claude-code/hooks | Deterministic pre/post tool-use and stop hooks |
| Aider modes | https://aider.chat/docs/usage/modes.html | Architect/editor split for separating design from edits |
| Aider lint/test | https://aider.chat/docs/usage/lint-test.html | Automatic lint/test feedback loops after changes |
| Cursor rules | https://docs.cursor.com/context/rules | Project rules as IDE-side agent context |
| GitHub Copilot instructions | https://docs.github.com/en/copilot/how-tos/custom-instructions/adding-repository-custom-instructions-for-github-copilot | Repository custom instructions for Copilot |
| Cline rules | https://docs.cline.bot/features/cline-rules | Repository and mode-specific rules |
| Windsurf rules | https://docs.windsurf.com/windsurf/cascade/memories#rules | IDE rules and memory-like context |
| Gemini CLI memory | https://github.com/google-gemini/gemini-cli/blob/main/docs/cli/configuration.md#context-files-hierarchical-instructional-context | Hierarchical `GEMINI.md` context files |

## Mechanism Extraction Matrix

| Source | Strong mechanism | Problem addressed | Absorb into kit | Template landing point |
| --- | --- | --- | --- | --- |
| GitHub Spec Kit | Lifecycle: spec, plan, tasks, implementation | Agents jump from idea to code without stable requirements | Yes | `docs/specs/`, `docs/designs/`, `docs/plans/`, `docs/tasks/` |
| GitHub Spec Kit | Constitution / project principles | Local plans violate cross-project principles | Yes | `docs/CONSTITUTION.md`, checked by guard scripts |
| Kiro Specs | Separate requirements, design, tasks | Requirements, architecture, and execution blur together | Yes | Distinct spec files with approval states |
| Kiro Specs | User approval gates before progressing | AI executes before design is reviewed | Yes | `spec_status`, `design_status`, `plan_status` in `AI_STATE.yml` |
| Codex exec plans | Self-contained plan file for long tasks | Context loss and unclear resumption | Yes | `docs/plans/T-xxx-plan.md` with progress and decisions |
| Codex exec plans | Plan update discipline during execution | Plan becomes stale while work continues | Yes | `scripts/plan-step.sh` requires step state updates |
| Codex AGENTS.md | Repository-local startup instructions | Agent starts without local conventions | Already partly absorbed | `AGENTS.md`, `docs/AI_RULES_INDEX.md` |
| Codex operating model | Environment, branch, task, PR/review boundaries | Agent completion is not auditable | Yes | closeout reports, git checkpoints, CI guard |
| Claude Code | CLAUDE.md as concise map | Long prompts are ignored or diluted | Already partly absorbed | `CLAUDE.md` indexes deeper protocol docs |
| Claude Code | Plan mode / think-before-edit | AI edits before enough reasoning | Yes | plan lock required before implementation |
| Claude Code hooks | Deterministic hooks for tool use and stop events | Prompt-only rules are bypassable | Yes | git hooks, `plan-guard.sh`, CI guard |
| Claude Code permissions | Explicit allow/deny around tools and paths | Agents touch dangerous paths | Yes | step-level allowed changes and forbidden changes |
| Aider architect/editor | Separate architect from editor | Same agent invents plan while editing | Yes | `PLAN_LOCKED` before edit; plan changes require separate state |
| Aider lint/test | Run lint/tests as feedback loop | Agent assumes changes work | Already partly absorbed | `drift-guard.sh`, profile guards, task closeout |
| Cursor rules | Repo/project rules attached to IDE context | Tool-specific agents miss AGENTS.md | Already partly absorbed | `.cursor/rules/vibecoding.mdc` |
| GitHub Copilot instructions | Repo custom instructions | Copilot chat lacks project protocol | Already partly absorbed | `.github/copilot-instructions.md` |
| Cline rules | Mode and workspace rules | Tool has its own planning/execution modes | Already partly absorbed | `.clinerules`, future mode notes |
| Windsurf rules | IDE rules and memory | Agent context differs by IDE | Already partly absorbed | `.windsurfrules` |
| Gemini memory | Hierarchical context files | Agent context depends on directory | Already partly absorbed | `GEMINI.md` |

## Strength Ranking

| Mechanism type | Strength | Reason |
| --- | --- | --- |
| Natural-language rule only | Weak | Useful as guidance, easy to ignore or forget |
| Repository instruction file | Medium | Improves startup context but still prompt-level |
| Separate spec/design/plan/task files | Medium-high | Creates auditable artifacts and better handoff |
| Locked plan with step state | High | Makes drift visible and resumable |
| Path allowlist per step | High | Makes unauthorized edits script-detectable |
| Guard scripts and closeout checks | High | Blocks completion on objective violations |
| Git hooks and CI | Very high | Runs outside the agent's self-reporting loop |
| Protected branch / push discipline | Very high | Prevents unreviewed remote delivery |

## Consolidated Design Principles

| Principle | Source influence | Kit implication |
| --- | --- | --- |
| Plan before edit | Spec Kit, Kiro, Claude Code, Aider | No implementation unless `plan_status: locked` |
| Split artifacts by purpose | Kiro, Spec Kit | Requirements, design, plan, and task are separate files |
| Keep entry files short | Codex AGENTS.md, Claude Code | `AGENTS.md` and `CLAUDE.md` stay as indexes |
| Make drift machine-checkable | Claude hooks, Aider lint/test | `plan-guard.sh` and closeout compare changed files to current step |
| Preserve resumability | Codex exec plans | Plan contains current step, decisions, and verification history |
| Require explicit plan change | Aider architect/editor, Kiro approval | `PLAN_CHANGE_REQUIRED` is a first-class blocked state |
| Verify before completion | Aider lint/test, existing kit rules | closeout includes tests, guards, checkpoint state |
| Tool adapters are secondary | Cursor, Copilot, Cline, Windsurf, Gemini | Adapters point to the same plan protocol, not separate workflows |

## Proposed Plan-Engine State Model

`docs/AI_STATE.yml` should become the task workflow state file:

```yml
current_task: T-001
workflow_status: implementation
requirements_status: approved
design_status: approved
plan_status: locked
current_step: S-003
allowed_next_steps:
  - S-003
require_plan_guard: true
require_step_commit: true
plan_change_status: none
```

Allowed status values:

| Field | Values | Meaning |
| --- | --- | --- |
| `requirements_status` | `draft`, `approved`, `change_required` | Requirements cannot be skipped |
| `design_status` | `draft`, `approved`, `change_required` | Design cannot be skipped for medium/high risk work |
| `plan_status` | `draft`, `locked`, `change_required` | Implementation requires locked plan |
| `workflow_status` | `planning`, `implementation`, `blocked`, `closeout`, `complete` | Top-level task lifecycle |
| `plan_change_status` | `none`, `requested`, `approved`, `rejected` | Any scope drift must be explicit |

## Proposed File Layout

```txt
docs/CONSTITUTION.md
docs/specs/T-xxx-requirements.md
docs/designs/T-xxx-design.md
docs/plans/PLAN_TEMPLATE.md
docs/plans/T-xxx-plan.md
docs/tasks/T-xxx.md
reports/ai-closeout/T-xxx.md
```

## Proposed Scripts

| Script | Purpose | Blocks when |
| --- | --- | --- |
| `scripts/spec-lint.sh T-xxx` | Check requirements/design/plan/task structure | Required sections missing |
| `scripts/plan-lock.sh T-xxx` | Validate and lock plan | Specs not approved, plan incomplete |
| `scripts/plan-guard.sh T-xxx S-xxx` | Check current state and changed files | Step mismatch, unlocked plan, unauthorized files |
| `scripts/plan-step.sh T-xxx S-xxx --complete` | Advance step state | Step not current, guards/tests missing |
| `scripts/task-closeout.sh` integration | Enforce final plan/guard state | Plan drift, skipped steps, no checkpoint |

## Drift Scenarios To Test

| Scenario | Expected block |
| --- | --- |
| AI edits before `plan_status: locked` | `PLAN_GUARD_FAIL: plan not locked` |
| AI edits files outside current step allowlist | `PLAN_GUARD_FAIL: unauthorized file` |
| AI skips from `S-001` to `S-003` | `PLAN_STEP_FAIL: step is not current` |
| AI modifies plan while locked without change request | `PLAN_GUARD_FAIL: locked plan changed` |
| AI completes with failed guard | `task-closeout.sh` exits non-zero |
| AI claims done without commit | closeout reports `NO_COMMIT_CHECKPOINT` |
| API work without contract-first spec | `api-contract-lint.sh` exits non-zero |

## What Not To Absorb

| Candidate | Reason |
| --- | --- |
| Tool-specific long prompts copied into every adapter | Causes drift between tools and wastes context |
| Fully automated implementation after vague idea | High risk; violates plan-before-edit principle |
| One giant master rules file | Hard to read, easy for agents to ignore |
| Tool-specific state as source of truth | Native todos are not portable across agents |
| Human-free approval for high-risk scope changes | Defeats the purpose of plan locking |

## Gaps And Follow-Up Research

| Gap | Current handling |
| --- | --- |
| Some IDE docs change quickly | Keep adapter files thin and source-of-truth in project docs |
| Community failure cases not fully reviewed yet | Use the drift scenarios above as regression tests first |
| Roo and Windsurf conventions may evolve | Treat current adapter rules as entry pointers, not core mechanics |
| Permissions differ per tool | Use repository scripts/hooks as the portable enforcement layer |

## Decision

Implement plan-engine as a lightweight workflow engine:

1. Spec/design/plan/task files provide auditable intent.
2. `AI_STATE.yml` records lifecycle and current step.
3. `plan-lock.sh`, `plan-guard.sh`, and `plan-step.sh` provide deterministic gates.
4. `task-closeout.sh` becomes the final enforcement point.
5. Tool adapters remain thin and point to the same protocol.

This combines the strongest reusable ideas from the benchmark without binding
the kit to one vendor's workflow.
