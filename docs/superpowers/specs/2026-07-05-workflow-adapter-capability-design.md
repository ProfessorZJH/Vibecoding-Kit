# Workflow and Adapter Capability Design

## Summary

T-003 adds a documentation-only workflow layer and adapter capability matrix to
Vibecoding Kit. The purpose is to make the v0.2.0 governance stack easier for
different AI coding tools to follow without adding runtime behavior.

## Recommended Approach

Use a docs + adapters + tests scope:

- Add reusable workflow phase documents under `core/workflows/`.
- Add `docs/adapter-capabilities.md` as the public capability matrix.
- Update adapter entry files to point agents to installed `workflows/`.
- Update README architecture language.
- Extend `scripts/test-kit.sh` so installation and adapter coverage are
  verified.

This is preferred over a docs-only change because the workflows need to be
reachable from generated projects and adapter entry files. It is also preferred
over managed sync or CLI work because those introduce runtime behavior before
the workflow contract is stable.

## Architecture

The post-T-003 architecture is:

```text
Prompt -> Workflow -> Policy -> Guard -> Report
```

Prompt modules describe behavior by mode. Workflow documents describe the task
lifecycle. Policy files define boundaries. Guard scripts verify violations.
Reports preserve evidence.

## Scope Boundaries

T-003 does not add a CLI, YAML parser, command executor, sandbox, managed
adapter block, or new guard behavior. It only documents the workflow and wires
adapter entry files to it.

## Review Notes

The main risk is duplication with existing adapter bridge docs. The workflow
layer should stay phase-oriented, while bridge docs stay tool-oriented. The
adapter capability matrix links the two without replacing either.
