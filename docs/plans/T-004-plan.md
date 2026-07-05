# T-004 Managed Adapter Blocks Plan

status: locked

## S-001 Add T-004 Source Of Truth

status: completed

allowed_changes:
- docs/tasks/T-004.md
- docs/specs/T-004-requirements.md
- docs/designs/T-004-design.md
- docs/plans/T-004-plan.md
- docs/superpowers/specs/2026-07-05-managed-adapter-blocks-design.md

forbidden_changes:
- core/scripts/**
- core/AGENTS.md
- core/CLAUDE.md
- profiles/agent-adapters/**
- docs/adapter-managed-blocks.md
- docs/releases/**
- README.md
- scripts/test-kit.sh
- installer/**
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- git diff --check

expected:
- T-004 source-of-truth files exist
- plan steps define allowed changes and verification commands

commit:
- required

## S-002 Add Failing Managed Block Tests

status: completed

allowed_changes:
- scripts/test-kit.sh

forbidden_changes:
- docs/tasks/**
- docs/specs/**
- docs/designs/**
- docs/plans/**
- docs/superpowers/**
- core/scripts/**
- core/AGENTS.md
- core/CLAUDE.md
- profiles/agent-adapters/**
- docs/adapter-managed-blocks.md
- docs/releases/**
- README.md
- installer/**
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- bash scripts/test-kit.sh

expected:
- test-kit fails before implementation because managed block script or markers are missing

commit:
- required after implementation makes tests pass

## S-003 Implement Adapter Block Script and Markers

status: completed

allowed_changes:
- core/scripts/adapter-block.sh
- core/AGENTS.md
- core/CLAUDE.md
- profiles/agent-adapters/root/**
- docs/adapter-managed-blocks.md

forbidden_changes:
- docs/tasks/**
- docs/specs/**
- docs/designs/**
- docs/plans/**
- docs/superpowers/**
- docs/releases/**
- README.md
- scripts/test-kit.sh
- installer/**
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- bash -n core/scripts/*.sh
- bash scripts/test-kit.sh

expected:
- adapter-block.sh supports --check and --update
- adapter files contain exactly one managed block
- managed block update preserves user content outside markers
- KIT_TESTS_PASS

commit:
- required

## S-004 Document Release Boundary

status: completed

allowed_changes:
- README.md
- docs/releases/v0.4.0.md

forbidden_changes:
- docs/tasks/**
- docs/specs/**
- docs/designs/**
- docs/plans/**
- docs/superpowers/**
- core/scripts/**
- core/AGENTS.md
- core/CLAUDE.md
- profiles/agent-adapters/**
- scripts/test-kit.sh
- installer/**
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- git diff --check
- bash scripts/test-kit.sh

expected:
- README links managed adapter block docs and v0.4.0 release notes
- v0.4.0 release note documents scope and known limits
- KIT_TESTS_PASS

commit:
- required

## S-005 Verify and Close Out T-004

status: completed

allowed_changes:
- docs/plans/T-004-plan.md

forbidden_changes:
- core/scripts/**
- core/AGENTS.md
- core/CLAUDE.md
- profiles/agent-adapters/**
- docs/adapter-managed-blocks.md
- docs/releases/**
- README.md
- scripts/test-kit.sh
- installer/**
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- git diff --check
- bash -n core/scripts/*.sh
- bash scripts/test-kit.sh

expected:
- all T-004 steps are completed
- whitespace check passes
- shell syntax check passes
- KIT_TESTS_PASS

commit:
- required
