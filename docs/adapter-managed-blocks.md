# Managed Adapter Blocks

Managed adapter blocks let Vibecoding Kit update generated adapter content
without overwriting local user notes in the same file.

## Marker Format

Adapter files use exact marker lines:

```md
<!-- VIBECODING-KIT:BEGIN -->
managed adapter protocol content
<!-- VIBECODING-KIT:END -->
```

Content inside the block is owned by Vibecoding Kit. Content before or after the
block is user-owned and must be preserved by update tools.

## Commands

Validate a file:

```bash
bash scripts/adapter-block.sh --check AGENTS.md
```

Replace only the managed block in a target file:

```bash
bash scripts/adapter-block.sh --update AGENTS.md templates/AGENTS.md
```

The update command copies the block from the template, including both marker
lines, and keeps the target file's content outside the block unchanged.

## Safety Rules

- A valid file has exactly one begin marker and exactly one end marker.
- The begin marker must appear before the end marker.
- Missing, duplicate, or malformed markers fail closed.
- `--update` validates both target and template before writing.
- The script does not insert markers heuristically.
- The script does not sync files into global AI tool directories.

## Intended Use

T-004 provides a safe primitive for future adapter updates. It is not a CLI and
does not decide which adapter files should be updated. Future workflows can use
`adapter-block.sh` after a human or tool has selected a target adapter file and
a trusted template.
