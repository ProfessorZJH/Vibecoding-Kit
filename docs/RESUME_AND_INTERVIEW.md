# Vibecoding Kit Resume and Interview Notes

## Purpose

Use this page when turning Vibecoding Kit into resume bullets, project summary
copy, and interview discussion. The safe framing is simple: this is a
repository-level governance layer around AI-assisted development, not a new AI
model and not a business application.

The Java backend governance demo is the strongest concrete example. It shows a
service-only task where `OrderService.java` is allowed, while runtime
configuration or dependency edits become drift and risk evidence.

## Resume Bullets

- Built Vibecoding Kit, a repository-level governance kit for AI coding agents
  that stores task state, locked plans, policy boundaries, and closeout evidence
  inside the repository.
- Implemented shell-based guard and reporting workflows for plan drift,
  unauthorized file changes, secret scanning, command risk classification, risk
  reports, Git checkpoint checks, and task closeout reports.
- Added a Java backend governance demo that simulates a service-layer task and
  detects AI-assisted drift into runtime configuration or dependency-sensitive
  files.
- Packaged reusable profiles and agent adapter entry files for Codex, Claude
  Code, Superpowers, Cursor, Cline, Roo, Windsurf, Gemini, and GitHub Copilot.
- Added regression demos and release quality checks covering generated project
  installs, installer UX, repeat-install safety, readability, and demo output
  markers.

## Project Summary

Vibecoding Kit makes the repository the source of truth for AI-assisted
development. Task cards define what is allowed, locked plans define the current
step, policy files define path and command boundaries, guard scripts detect
drift, and closeout reports preserve evidence for review.

The project does not claim to prove business correctness or make AI perfectly
safe. Its value is making explicit process drift visible, repeatable, and
auditable.

## Interview Talk Track

### 30-Second Version

I built Vibecoding Kit as the governance layer around AI coding tools. When AI
tasks get long, the chat context, original plan, repository state, and final
diff can diverge. This kit moves the task contract into repository files and
uses guard scripts and reports to detect, block, and audit that drift.

### Java Backend Version

The Java backend governance demo is the most practical example. The task only
allows changes to `OrderService.java`, then the demo simulates an AI-assisted
change to `application.yml`. The guard catches the unauthorized file, the risk
report marks the runtime configuration change as HIGH risk, and closeout writes
reviewable evidence.

That is the project value for backend work: it is not just using AI to generate
classes. It is putting AI-assisted changes back inside normal engineering
boundaries such as service-layer scope, runtime configuration safety, Git
checkpoints, and review evidence.

### Agent Engineering Version

For an AI engineering discussion, frame the project as a repository contract for
multiple coding agents. Prompts guide behavior, policies define boundaries,
guards check what actually changed, and reports preserve evidence. The same
contract can be used by Codex, Claude Code, Cursor, Cline, Roo, Windsurf,
Gemini, GitHub Copilot, and similar tools.

## What Not To Claim

- Do not claim the kit guarantees AI will never drift.
- Do not claim the kit replaces code review, tests, or product judgment.
- Do not claim HIGH risk evidence is a full deployment blocker.
- Do not describe the project as only prompt engineering.
- Do not describe it as a mature packaged CLI product.

## Strong Closing Line

Vibecoding Kit turns AI coding from a chat-only workflow into a repository-level
contract with task state, policy boundaries, guard checks, and reviewable
closeout evidence.
