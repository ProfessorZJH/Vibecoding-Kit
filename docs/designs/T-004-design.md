# T-004 Design

status: approved

## Architecture

T-004 adds an Adapter maintenance layer to the existing architecture:

```text
Prompt -> Workflow -> Policy -> Guard -> Report -> Adapter Maintenance
```

The new layer is deliberately small. Adapter files declare a single managed
block owned by Vibecoding Kit. Users may keep project-specific content before
or after the block. `adapter-block.sh` validates the marker structure and can
replace the managed block with the block from a template file.

## Marker Contract

Managed content is bounded by exact marker lines:

```md
<!-- VIBECODING-KIT:BEGIN -->
managed adapter protocol content
<!-- VIBECODING-KIT:END -->
```

Each managed adapter file must contain exactly one begin marker and exactly one
end marker. The begin marker must appear before the end marker. The script does
not support nested blocks or multiple blocks in the same file.

## Script Interface

`core/scripts/adapter-block.sh` is installed into generated projects as
`scripts/adapter-block.sh`.

```bash
bash scripts/adapter-block.sh --check AGENTS.md
bash scripts/adapter-block.sh --update AGENTS.md templates/AGENTS.md
```

`--check` prints `ADAPTER_BLOCK_PASS` on success. It prints
`ADAPTER_BLOCK_FAIL` with a reason on failure.

`--update` validates the target and template first. If both are valid, it writes
a temporary file that combines:

1. target content before the target begin marker
2. template content from template begin marker through template end marker
3. target content after the target end marker

The script then atomically moves the temporary file over the target.

## Error Handling

- Missing file: fail.
- Missing begin or end marker: fail.
- Duplicate begin or end marker: fail.
- End marker before begin marker: fail.
- Missing template in `--update`: fail.
- Any validation failure in target or template: fail.

The script never inserts markers heuristically. A missing block means the file
is not safe for automated update.

## Files

- `core/scripts/adapter-block.sh`: validation and safe block replacement.
- `docs/adapter-managed-blocks.md`: user-facing convention and examples.
- `core/AGENTS.md` and `core/CLAUDE.md`: core adapter files with managed
  blocks.
- `profiles/agent-adapters/root/**`: optional agent adapter files with managed
  blocks.
- `scripts/test-kit.sh`: behavioral and installation coverage.
- `README.md`: documentation link and layer summary.
- `docs/releases/v0.4.0.md`: release note.

## Testing

`scripts/test-kit.sh` covers:

- source adapter marker presence
- installed adapter marker presence
- installed `scripts/adapter-block.sh` executable
- `--check` pass on valid file
- `--check` failure on missing markers
- `--check` failure on duplicate markers
- `--check` failure on malformed marker order
- `--update` replacing only the managed block
- user content before and after the block preserved

## Limits

T-004 does not sync adapters automatically and does not decide where adapter
files should be installed. It only provides a safe primitive that future update
flows can use.
