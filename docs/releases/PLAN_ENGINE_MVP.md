# Plan Engine MVP

Release date: 2026-07-04

## Purpose

The Plan Engine turns AI planning into a repository-enforced workflow. It does
not assume one AI tool. It lets native planning features exist, but requires the
final executable plan to live in repository files.

## Included Capabilities

- Requirements, design, plan, and task templates.
- Installed generated-project workflow guide.
- Machine-readable state in `docs/AI_STATE.yml`.
- Plan locking through `scripts/plan-lock.sh`.
- Step execution through `scripts/plan-step.sh`.
- Drift and step validation through `scripts/plan-guard.sh`.
- Closeout integration through `scripts/drift-guard.sh` and
  `scripts/task-closeout.sh`.
- Commit checkpoint enforcement for steps that require commits.
- Adapter docs for Codex, Claude Code, Superpowers, Gemini, Cursor, Windsurf,
  Cline, Roo, and GitHub Copilot.
- API contract profile for designing APIs before implementation and reconciling
  generated Swagger/OpenAPI afterward.

## Installed Project Contract

A generated project starts with `T-000` locked and ready. Future tasks should
follow this contract:

```bash
bash scripts/spec-lint.sh T-xxx
bash scripts/plan-lock.sh T-xxx
bash scripts/plan-step.sh T-xxx S-001 --start
git add .
git commit -m "T-xxx: describe the step"
bash scripts/plan-step.sh T-xxx S-001 --complete
bash scripts/drift-guard.sh
bash scripts/task-closeout.sh T-xxx --write-report
```

## Guarded Failure Modes

- Missing task id or invalid task id.
- Missing requirements, design, plan, or task files.
- Unsupported artifact status.
- Plan not locked.
- Missing or placeholder plan hash.
- Locked plan changed after lock.
- Requested step is not the current step.
- Changed files are outside the current step allowlist.
- Forbidden files are changed.
- Step completion without a required commit checkpoint.
- Closeout without required test command when tests are not skipped.

## Limitations

- Shell guards can only enforce what they can inspect in the repository.
- Semantic correctness still needs tests, review, and human judgment.
- A tool can still ignore a failing command unless the user workflow treats guard
  failure as blocking.
- Remote push depends on repository remotes, credentials, branch protection, and
  explicit user intent.

## Verification

Run from this kit repository:

```bash
bash scripts/test-kit.sh
git diff --check
```

`scripts/test-kit.sh` installs sample projects and verifies positive and
negative Plan Engine paths.
