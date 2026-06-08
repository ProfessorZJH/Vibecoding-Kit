# Vibecoding Kit Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a reusable vibecoding project operating-system kit that can initialize AI rules, task cards, guard scripts, hooks, CI, and optional stack/domain profiles into new projects.

**Architecture:** The kit is split into `core` templates, optional `profiles`, and an `installer` that copies and merges them into a target project. Guard scripts are shell-based, self-tested, and avoid project-specific business assumptions unless a profile is selected.

**Tech Stack:** POSIX shell/Bash, Markdown templates, YAML templates, Git hooks, GitCode/GitHub workflow templates.

---

### Task 1: Kit Self-Test

**Files:**
- Create: `scripts/test-kit.sh`

- [ ] **Step 1: Write the failing test**

Create a shell test that initializes temporary projects with `core + ddd + finance` and with `core + java-spring + vue + ddd + finance`, then checks generated files and guard commands.

- [ ] **Step 2: Run test to verify it fails**

Run: `bash scripts/test-kit.sh`
Expected: FAIL because `installer/init.sh` and templates do not exist.

### Task 2: MVP Core, DDD, and Finance Profiles

**Files:**
- Create: `core/**`
- Create: `profiles/ddd/**`
- Create: `profiles/finance/**`
- Create: `installer/init.sh`

- [ ] **Step 1: Implement minimal templates**

Add generic AI state, task template, project state, git checkpoint, guard scripts, DDD architecture guard, and finance safety rules.

- [ ] **Step 2: Run MVP test**

Run: `bash scripts/test-kit.sh`
Expected: PASS for MVP initialization.

- [ ] **Step 3: Commit MVP**

Commit message: `feat: add vibecoding kit MVP`

### Task 3: Full Java, Vue, and CI Profiles

**Files:**
- Create: `profiles/java-spring/**`
- Create: `profiles/vue/**`
- Create: `core/workflows/**`
- Modify: `installer/init.sh`
- Modify: `README.md`

- [ ] **Step 1: Add stack profiles**

Add Java/Spring and Vue guard scripts, docs, and workflow fragments.

- [ ] **Step 2: Add CI templates**

Add GitCode and GitHub workflow templates and installer support for `--ci gitcode` / `--ci github`.

- [ ] **Step 3: Run full self-test**

Run: `bash scripts/test-kit.sh`
Expected: PASS for full initialization.

- [ ] **Step 4: Commit full kit**

Commit message: `feat: add stack profiles and CI templates`

### Task 4: Final Verification

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Run complete verification**

Run: `bash scripts/test-kit.sh && git status --short`
Expected: tests pass and worktree clean after final commit.
