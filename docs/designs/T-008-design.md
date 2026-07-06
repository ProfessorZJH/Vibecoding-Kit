# T-008 Design

status: approved

## Architecture

T-008 changes installer writes from direct target copy to a staged payload
merge:

```text
parse args -> build payload in temp staging -> plan target changes -> dry-run or merge
```

The staging directory receives the same core, profile, CI, XFG, token
replacement, plan hash, executable bit, and optional init report operations that
used to run directly against the target. This preserves first-install behavior,
including profile overlays such as `agent-adapters` replacing core
`AGENTS.md` and `CLAUDE.md`.

The merge step is conservative:

- missing target file: create it
- existing identical file: skip it
- existing different file: report conflict and preserve the target file

## Dry-Run

`--dry-run` builds the staging payload and compares it with the target path
without writing to the target. If the target directory does not exist, dry-run
must not create it.

Dry-run output is line-oriented and stable enough for tests:

```text
VIBECODING_KIT_DRY_RUN
target: /path/to/project
project: dry-run-demo
profiles: agent-adapters
ci: none
will_create:
  docs/AI_STATE.yml
will_skip_existing:
  none
will_conflict:
  none
DRY_RUN_PASS
```

## Merge Output

Normal install keeps the existing `VIBECODING_KIT_INIT_PASS` summary for
compatibility and adds conflict/skip information when relevant.

When conflicts exist, the installer reports:

```text
VIBECODING_KIT_INSTALL_CONFLICT
will_conflict:
  AGENTS.md
```

and exits non-zero after preserving target content.

## Doctor Script

`core/scripts/ai-doctor.sh` is installed into target projects as
`scripts/ai-doctor.sh`. It checks the generated project from its current
working directory.

It verifies:

- `docs/AI_STATE.yml`
- `docs/tasks/T-000.md`
- `docs/plans/T-000-plan.md`
- executable `scripts/ai-preflight.sh`
- executable `scripts/drift-guard.sh`
- executable `scripts/task-closeout.sh`
- executable `scripts/risk-report.sh`
- executable `scripts/secrets-guard.sh`

The output is stable:

```text
DOCTOR
docs/AI_STATE.yml: ok
scripts/ai-preflight.sh: executable
DOCTOR_PASS
```

Missing files or non-executable scripts print `DOCTOR_FAIL` and exit non-zero.

## Testing

`scripts/test-kit.sh` adds coverage for:

- dry-run on a nonexistent target does not create the target
- dry-run lists key files and prints `DRY_RUN_PASS`
- generated target contains executable `scripts/ai-doctor.sh`
- target doctor prints `DOCTOR_PASS`
- repeat install over an unchanged target skips identical files
- repeat install over a user-modified generated file fails with conflict
- conflicting user content is preserved byte-for-byte

## Limits

T-008 does not implement automatic backups, uninstall, rollback, global sync,
package publishing, CLI wrapping, or managed updates for every generated file.
It does not change guard, risk, closeout, adapter block, or policy semantics.
