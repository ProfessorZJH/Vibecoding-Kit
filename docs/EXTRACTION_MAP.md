# Extraction Map

This map separates reusable vibecoding rules from project-specific rules.

## Core

- AI entry rules.
- Machine-readable AI state.
- Project state.
- Task card template.
- Git commit / push checkpoints.
- Preflight and closeout scripts.
- Drift guard orchestration.
- Git hook installer.
- Closeout reports.

## DDD Profile

Source baseline:

```txt
io.github.fuzhengwei:ddd-scaffold-lite-jdk17:1.7
```

The profile vendors the original Maven archetype resources under:

```txt
profiles/ddd/xfg-archetype
```

Generated projects receive the same reference under:

```txt
docs/reference/xfg-ddd-scaffold-lite-jdk17
```

## Finance Profile

- AI may recommend only.
- Sensitive financial actions require permission and audit.
- Amounts and status transitions cannot be bypassed.
- Formal financial data must not be mutated by AI.

## Stack Profiles

- `java-spring`: Maven/Java/Spring checks.
- `vue`: npm/Vue checks.
