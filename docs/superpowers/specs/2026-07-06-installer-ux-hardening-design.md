# Installer UX Hardening Design

## Summary

T-008 hardens the shell installer with dry-run output, a generated project
doctor script, and repeat-install safety. The installer remains shell-first and
does not become a CLI framework.

## Scope

- Add `installer/init.sh --dry-run`.
- Install `scripts/ai-doctor.sh` from `core/scripts/ai-doctor.sh`.
- Make repeat installation preserve existing files with different content.
- Add test-kit coverage for dry-run, doctor, and repeat-install conflicts.
- Update README, CHANGELOG, and v0.7.0 release notes.

## Non-Scope

- No TypeScript or Node CLI.
- No YAML parser.
- No uninstall or rollback automation.
- No global AI tool directory sync.
- No network dependency.
- No guard, risk, closeout, adapter block, or policy semantic changes.

## Chosen Approach

Build the intended install payload in a temporary staging directory first, then
compare the staging tree against the target. This preserves existing first
install behavior, including profile overlays, while giving dry-run and normal
install the same file plan.

Normal install creates missing files, skips identical files, and reports
conflicts for existing files with different content. Conflict files are not
overwritten. This gives repeat installs a safe default without trying to solve
automatic merge or rollback in T-008.

## Alternatives Considered

1. Skip every existing file during copy.
   This is rejected because first-install profile overlays rely on later profile
   payloads replacing core defaults before the target is finalized.
2. Backup and overwrite conflicts.
   This is deferred because it increases state management and rollback
   complexity. T-008 should preserve user content by default.
3. Add an external doctor command in the kit repo only.
   This is rejected because users need a check inside generated target projects.

## Acceptance

The work is complete when dry-run prints `DRY_RUN_PASS` without modifying the
target, generated projects include `scripts/ai-doctor.sh`, doctor prints
`DOCTOR_PASS` in a healthy target, repeat install preserves conflicting user
content, README documents the workflow, and `bash scripts/test-kit.sh` passes.
