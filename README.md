# Vibecoding Kit

Reusable project operating-system templates for AI-assisted development.

The kit installs file-based memory, task cards, guard scripts, Git checkpoints,
hooks, CI workflows, closeout reports, and optional stack/domain profiles into a
target project.

## Quick Start

```bash
bash installer/init.sh \
  --target /path/to/project \
  --name my-project \
  --profile ddd \
  --profile finance \
  --ci gitcode
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
  --ci gitcode \
  --ci github
```

## Profiles

- `ddd`: uses the exact `io.github.fuzhengwei:ddd-scaffold-lite-jdk17:1.7`
  archetype resources as the DDD reference baseline.
- `finance`: financial safety, audit, permission, and AI execution boundaries.
- `java-spring`: Java/Spring guard docs and CI commands.
- `vue`: Vue guard docs and CI commands.

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
