# Vibecoding Kit Positioning

This document packages Vibecoding Kit into wording that is usable in README
copy, resume bullets, and interview discussion without overstating what the kit
does.

For a Chinese interview-oriented talk track, see
[docs/INTERVIEW_CN.md](INTERVIEW_CN.md).

## One-Sentence Positioning

Vibecoding Kit is a repository-level governance kit for AI coding agents. It
combines task cards, locked plans, policy files, guard scripts, and closeout
reports to detect, block, and audit AI task drift in real projects.

## README Version

Use this when you need a short project description:

> Vibecoding Kit is not a business system or a new coding model. It is the
> governance layer around AI-assisted development: repository files become the
> source of truth, and shell guards verify whether the agent stayed inside the
> current task, current step, allowed file scope, command policy, and closeout
> requirements.

## Resume Version

Use concrete, engineering-facing language. Do not claim perfect control over AI
behavior.

- Designed and implemented Vibecoding Kit, a repository-level governance tool
  for AI coding agents that turns task cards, requirements, design notes, and
  locked execution plans into machine-checkable project state.
- Built shell-based guard and reporting workflow covering plan lock, current
  step enforcement, unauthorized file detection, secrets scanning, command risk
  classification, risk reporting, Git checkpoint checks, and closeout evidence.
- Added reusable profiles and adapter entry points for Codex, Claude Code,
  Superpowers, Cursor, Cline, Roo, Windsurf, Gemini, and GitHub Copilot so
  different tools can follow the same repository contract.
- Wrote integration tests and demos that install temporary sample projects and
  verify both positive paths and drift failures such as unlocked plans,
  out-of-scope file edits, missing checkpoints, and blocked high-risk commands.

## Interview Version

### 30-Second Answer

This project is not trying to replace Codex or Claude Code. I built the
governance layer around them. The problem I ran into was that once AI tasks got
long, the native plan, the chat context, the repository state, and the actual
diff often diverged. Vibecoding Kit makes the repository the source of truth,
then uses plans, policy files, guard scripts, and reports to detect, block, and
audit that drift.

### Problem Framing

The core problem is not "AI writes bad code" in a generic sense. The more
practical problem is that AI agents can:

- change files outside the intended task scope
- continue implementing after the plan changed
- skip checkpoints and closeout evidence
- run commands that are riskier than the task justifies

Those failures are hard to manage if the only source of truth is the chat
window. They become much easier to manage if the repository stores the current
task, current step, allowed files, plan lock, and verification outputs.

### Architecture Framing

I explain the project in four layers:

1. Prompt layer: tell the agent how to work.
2. Policy layer: define path, command, and risk boundaries.
3. Guard layer: verify plan state, file scope, secret safety, and command
   classification.
4. Report layer: preserve risk and closeout evidence for review and handoff.

The important design choice is that prompt instructions are soft constraints.
The hard constraints live in repository files and guard scripts.

### What It Helps With

- makes repository state authoritative over chat history
- makes plan drift visible and blockable
- standardizes AI task execution across multiple coding tools
- leaves reviewable evidence instead of relying on "the agent said it was done"

### What It Does Not Claim

- it does not guarantee that AI will never drift
- it does not replace tests, code review, or product judgment
- it does not prove semantic correctness
- it only enforces what is visible from repository state and command execution

That limitation is important. The value proposition is not perfection. It is
practical governance.

## Useful Short Variants

### Short Chinese Version

Vibecoding Kit 不是新的 AI 编程模型，而是 AI 编程外面的仓库级治理层。它把任务卡、需求、设计、执行计划、策略文件、守卫脚本和收尾报告落到仓库里，让 AI 在长任务里的漂移变得可检测、可阻断、可审计。

### Short English Version

Vibecoding Kit is a repository-level governance kit for AI coding workflows. It
uses repository-native plans, policy files, guards, and reports to detect,
block, and audit task drift across different AI coding tools.
