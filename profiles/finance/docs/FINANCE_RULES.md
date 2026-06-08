# Finance Rules

Finance projects have higher safety requirements.

## P0 Boundaries

- Financial actions require permission and audit.
- Amount validation and state transitions must not be bypassed.
- Posted or finalized records must not be directly mutated.
- AI can recommend, explain, summarize, and warn, but must not execute formal
  financial actions.
- Sensitive fields must not be written to logs or closeout reports.

## Completion

High-risk finance tasks need review evidence and tests for permission, audit,
amount validation, and state transition behavior.
