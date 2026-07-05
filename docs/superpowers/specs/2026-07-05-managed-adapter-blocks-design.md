# Managed Adapter Blocks Design

## Summary

T-004 adds marker-based managed blocks for agent adapter files. The goal is to
make future adapter updates safe by replacing only generated Vibecoding Kit
content while preserving local user content before and after the block.

## Scope

- Use exact HTML comment markers:
  `<!-- VIBECODING-KIT:BEGIN -->` and
  `<!-- VIBECODING-KIT:END -->`.
- Add `core/scripts/adapter-block.sh`.
- Support `--check <file>` and `--update <file> <template>`.
- Add managed blocks to core and profile adapter files.
- Add documentation and test-kit coverage.

## Non-Scope

- No CLI.
- No global tool config sync.
- No automatic marker insertion.
- No template engine.
- No YAML parsing.
- No changes to existing guard semantics.

## Chosen Approach

Use a conservative marker replacement script. The script validates exactly one
begin marker and one end marker in both target and template. For updates, it
replaces the target block with the full template block and leaves everything
outside the target markers untouched.

This is intentionally stricter than heuristic insertion. If markers are
missing, duplicate, or malformed, the safe action is to fail and ask for manual
repair.

## Alternatives Considered

1. Insert managed blocks automatically when missing.
   This is rejected because the script cannot know where user-owned content
   should live.
2. Use a template engine with variables.
   This is rejected for v0.4.0 because adapter updates only need block-level
   replacement.
3. Build a full CLI.
   This is reserved for a later release after the safe primitive is proven.

## Acceptance

The work is complete when `bash scripts/test-kit.sh`, `bash -n core/scripts/*.sh`,
and `git diff --check` pass, and the test kit proves that user content around a
managed block survives an update unchanged.
