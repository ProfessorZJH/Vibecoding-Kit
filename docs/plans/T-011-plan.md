# T-011 Resume and Interview Positioning Closeout Plan

status: completed

## S-001 Add Failing Documentation Coverage

status: completed

allowed_changes:
- scripts/test-kit.sh

forbidden_changes:
- core/scripts/**
- installer/**
- profiles/**
- docs/policies/**
- examples/**

commands:
- bash -n scripts/test-kit.sh
- bash scripts/test-kit.sh

expected:
- test-kit expects T-011 task, plan, resume/interview notes, and positioning
  phrases.
- test-kit fails before implementation because `docs/tasks/T-011.md` is
  missing.

commit:
- required after all T-011 work passes verification

## S-002 Add Resume and Interview Material

status: completed

allowed_changes:
- docs/tasks/T-011.md
- docs/plans/T-011-plan.md
- docs/RESUME_AND_INTERVIEW.md

forbidden_changes:
- core/scripts/**
- installer/**
- profiles/**
- docs/policies/**
- examples/**

commands:
- git diff --check

expected:
- T-011 task card records scope, forbidden changes, tests, and completion
  criteria.
- T-011 plan records the documentation-only workflow.
- Resume and interview notes provide concise, non-overstated talking points.

commit:
- required after verification

## S-003 Refresh Public Positioning Docs

status: completed

allowed_changes:
- README.md
- docs/POSITIONING.md
- docs/INTERVIEW_CN.md

forbidden_changes:
- core/scripts/**
- installer/**
- profiles/**
- docs/policies/**
- examples/**

commands:
- bash scripts/readability-guard.sh
- bash scripts/test-kit.sh

expected:
- README points to the resume and interview notes.
- Positioning material names the Java service governance demo as the concrete
  backend scenario.
- Chinese interview notes include a direct Java Service Governance Demo hook.

commit:
- required after verification

## S-004 Verify and Publish

status: completed

allowed_changes:
- docs/tasks/T-011.md
- docs/plans/T-011-plan.md
- docs/RESUME_AND_INTERVIEW.md
- README.md
- docs/POSITIONING.md
- docs/INTERVIEW_CN.md
- scripts/test-kit.sh

forbidden_changes:
- core/scripts/**
- installer/**
- profiles/**
- docs/policies/**
- examples/**

commands:
- git diff --check
- bash -n scripts/test-kit.sh
- bash -n scripts/readability-guard.sh
- bash scripts/readability-guard.sh
- bash scripts/test-kit.sh

expected:
- Whitespace check passes.
- Shell syntax checks pass.
- Readability guard passes.
- KIT_TESTS_PASS.
- Local `master` is pushed to `origin/master`.

commit:
- required
