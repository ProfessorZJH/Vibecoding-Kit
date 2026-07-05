# Vibecoding Kit

[![test-kit](https://github.com/ProfessorZJH/Vibecoding-Kit/actions/workflows/test-kit.yml/badge.svg)](https://github.com/ProfessorZJH/Vibecoding-Kit/actions/workflows/test-kit.yml)

Reusable project operating-system templates for AI-assisted development.

The kit installs file-based memory, task cards, guard scripts, Git checkpoints,
hooks, CI workflows, closeout reports, and optional stack/domain profiles into a
target project.

It is not a business system. It is a reusable development template for new
projects that use Codex, Claude Code, Superpowers, Cursor, Cline, Roo,
Windsurf, Gemini, GitHub Copilot, or other AI coding agents.

## Project Positioning

Vibecoding Kit is not a new coding model and not a business application. It is
the repository-level governance layer around AI-assisted development: the
repository stores the current task, current step, plan lock, policy boundaries,
and closeout evidence, while guard scripts verify whether the agent stayed
inside that contract.

## What This Solves

AI agents drift when their native plan, chat context, repository state, and
actual changed files disagree. Vibecoding Kit makes the repository the source of
truth:

- `docs/AI_STATE.yml` records the current task, workflow status, plan lock, and
  current step.
- `docs/tasks/T-xxx.md` records allowed changes, forbidden actions, tests, and
  completion criteria.
- `docs/VIBECODING_WORKFLOW.md` gives each generated project a local operating
  guide for AI task execution.
- `docs/specs`, `docs/designs`, and `docs/plans` turn requirements, design, and
  implementation steps into auditable files.
- `scripts/plan-guard.sh`, `scripts/drift-guard.sh`, and
  `scripts/task-closeout.sh` detect unauthorized files, unlocked plans, changed
  locked plans, missing checkpoints, and closeout gaps.

The template does not make an AI perfect. It gives the project a way to detect,
block, and audit plan drift.

## 30-Second Demo

Run the drift demo:

```bash
bash examples/ai-drift-demo/run-demo.sh
```

The demo locks a plan step to one Java service file, then simulates an AI agent
also editing runtime configuration. The guard blocks the out-of-plan file:

```txt
DEMO_STEP unauthorized_change_blocked
PLAN_GUARD_FAIL: unauthorized file
src/main/resources/application.yml
```

After the plan is intentionally updated and relocked, the task can close out:

```txt
DEMO_STEP relocked_after_plan_update
DEMO_STEP closeout_report_written
DEMO_PASS
```

## Quick Start

```bash
bash installer/init.sh \
  --target /path/to/project \
  --name my-project \
  --profile ddd \
  --profile finance \
  --profile agent-adapters \
  --ci gitcode
```

For a generic project, start with:

```bash
bash installer/init.sh \
  --target /path/to/project \
  --name my-project \
  --profile agent-adapters \
  --ci none
```

For a Java/Spring + Vue + DDD finance project:

```bash
bash installer/init.sh \
  --target /path/to/project \
  --name my-project \
  --profile java-spring \
  --profile vue \
  --profile ddd \
  --profile finance \
  --profile api-contract \
  --profile agent-adapters \
  --ci gitcode \
  --ci github
```

## Profiles

- `core`: AI state, rules index, task cards, Plan Engine, drift guard,
  closeout, hooks, and CI workflow templates.
- `ddd`: uses the exact `io.github.fuzhengwei:ddd-scaffold-lite-jdk17:1.7`
  archetype resources as the DDD reference baseline.
- `finance`: financial safety, audit, permission, and AI execution boundaries.
- `java-spring`: Java/Spring guard docs and CI commands.
- `vue`: Vue guard docs and CI commands.
- `api-contract`: contract-first API planning before Swagger/OpenAPI output.
- `agent-adapters`: tool entry files for Codex, Claude Code, Gemini, Cursor,
  Windsurf, Cline, Roo, GitHub Copilot, and Superpowers-compatible planning.

## Plan-Locked Workflow

For each real task:

```bash
bash scripts/ai-preflight.sh T-001
bash scripts/spec-lint.sh T-001
bash scripts/plan-lock.sh T-001
bash scripts/plan-step.sh T-001 S-001 --start

# implement only files allowed by the current step
git add .
git commit -m "T-001: describe the step"

bash scripts/plan-step.sh T-001 S-001 --complete
bash scripts/drift-guard.sh
bash scripts/task-closeout.sh T-001 --write-report
```

If a remote push is required, closeout can report it:

```bash
bash scripts/task-closeout.sh T-001 --write-report --push
```

The default behavior requires local commit checkpoints. Remote push is reported
only when requested and possible.

## Modular Agent Prompts

Vibecoding Kit includes shared prompt modules for AI coding agents under
`core/prompts/`. When installed into a target project, they are copied to
`prompts/`.

The modules cover:

- global agent contract
- read-only exploration
- plan-locked task planning
- current-step implementation
- command risk classification
- high-confidence security review
- closeout reporting
- task memory summary for long sessions

Agent adapter files such as `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, Cursor,
Cline, Roo, Windsurf, and GitHub Copilot instructions reference these shared
modules instead of duplicating the full prompt text.

## Governance Layers

Vibecoding Kit uses layered governance for AI-assisted development:

1. Prompt layer: modular prompts for explore, plan, implement, security
   review, closeout, and memory summary.
2. Workflow layer: `workflows/` defines project scan, task creation, plan lock,
   implementation, risk review, and closeout phases.
3. Policy layer: `docs/policies/` defines sensitive paths, command classes, and
   file-change risk levels.
4. Guard layer: shell guards enforce plan drift checks, secret scanning, and
   command classification boundaries.
5. Report layer: risk and closeout reports preserve evidence for review and
   handoff.

The operating rule is simple: prompt guides behavior, workflow sequences action,
policy defines boundaries, guard checks violations, and report preserves
evidence.

## Verify The Kit

```bash
bash scripts/test-kit.sh
```

## Generated Project Commands

```bash
bash scripts/ai-preflight.sh T-000
bash scripts/drift-guard.sh
bash scripts/task-closeout.sh T-000 --no-tests --write-report
bash scripts/install-git-hooks.sh
```

## Documentation

- [Template Handbook](docs/TEMPLATE_HANDBOOK.md)
- [Positioning and Talk Track](docs/POSITIONING.md)
- [Chinese Interview Talk Track](docs/INTERVIEW_CN.md)
- [Plan Engine MVP](docs/releases/PLAN_ENGINE_MVP.md)
- [Policy, Command Guard, and Risk Report MVP](docs/releases/POLICY_COMMAND_RISK_MVP.md)
- [v0.2.0 Release Notes](docs/releases/v0.2.0.md)
- [v0.1.0 Release Notes](docs/releases/v0.1.0.md)
- [AI Drift Demo](examples/ai-drift-demo/README.md)
- [Examples](docs/EXAMPLES.md)
- [Extraction Map](docs/EXTRACTION_MAP.md)
- [Prompt Modules](core/prompts/README.md)
- [Adapter Capability Matrix](docs/adapter-capabilities.md)
