# T-006 Release Hygiene and Default Branch Alignment Plan

status: locked

## S-001 Check Default Branch and Tag Alignment

status: completed

allowed_changes:
- docs/tasks/T-006.md
- docs/plans/T-006-plan.md

forbidden_changes:
- README.md
- examples/README.md
- CHANGELOG.md
- core/scripts/**
- scripts/test-kit.sh
- installer/**
- profiles/**
- examples/*/run-demo.sh
- docs/policies/**
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- git fetch --tags origin
- git log --oneline --decorate -n 8
- git rev-parse HEAD
- git rev-parse origin/master
- git rev-parse v0.5.0
- git branch --contains v0.5.0
- git branch -r --contains v0.5.0

expected:
- HEAD, origin/master, and v0.5.0 all point to
  bd6f64428d0439c6130caebe365e5bb60d55f2f6 before T-006 edits
- master contains v0.5.0
- origin/master contains v0.5.0

commit:
- included in T-006 release hygiene commit

## S-002 Check README and Examples Index

status: completed

allowed_changes:
- docs/tasks/T-006.md
- docs/plans/T-006-plan.md
- README.md only if formatting is compressed or demo commands are missing
- examples/README.md only if formatting is compressed or demo commands are
  missing

forbidden_changes:
- CHANGELOG.md
- core/scripts/**
- scripts/test-kit.sh
- installer/**
- profiles/**
- examples/*/run-demo.sh
- docs/policies/**
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- wc -l README.md examples/README.md docs/releases/v0.5.0.md
- curl -fsSL -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/ProfessorZJH/Vibecoding-Kit/master/README.md?cachebust=<timestamp> | wc -l
- curl -fsSL -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/ProfessorZJH/Vibecoding-Kit/master/README.md?cachebust=<timestamp> | sed -n '35,65p'
- curl -fsSL -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/ProfessorZJH/Vibecoding-Kit/master/examples/README.md?cachebust=<timestamp> | wc -l
- curl -fsSL -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/ProfessorZJH/Vibecoding-Kit/master/examples/README.md?cachebust=<timestamp> | sed -n '1,40p'

expected:
- local README has normal Markdown line breaks and lists all four demos
- remote master README has normal Markdown line breaks and lists all four demos
- local examples/README.md has normal Markdown line breaks and lists all four
  demos
- remote master examples/README.md has normal Markdown line breaks and lists all
  four demos
- no README or examples index edit is required when checks pass

commit:
- included in T-006 release hygiene commit

## S-003 Update Changelog

status: completed

allowed_changes:
- CHANGELOG.md

forbidden_changes:
- README.md
- examples/README.md
- docs/tasks/**
- docs/plans/**
- core/scripts/**
- scripts/test-kit.sh
- installer/**
- profiles/**
- examples/*/run-demo.sh
- docs/policies/**
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
- CHANGELOG.md includes v0.5.0 Governance Demos and UX Polish
- changelog entry records added demos and unchanged release boundaries

commit:
- included in T-006 release hygiene commit

## S-004 Verify T-006

status: completed

allowed_changes:
- docs/tasks/T-006.md
- docs/plans/T-006-plan.md
- CHANGELOG.md

forbidden_changes:
- README.md
- examples/README.md
- core/scripts/**
- scripts/test-kit.sh
- installer/**
- profiles/**
- examples/*/run-demo.sh
- docs/policies/**
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- git diff --check
- bash -n scripts/test-kit.sh
- bash scripts/test-kit.sh
- git log --oneline --decorate -n 8
- git branch --contains v0.5.0

expected:
- whitespace check passes
- test-kit syntax check passes
- KIT_TESTS_PASS
- git log shows T-006 on top when committed
- local master contains v0.5.0

commit:
- required

## S-005 Recheck Markdown Readability

status: completed

allowed_changes:
- docs/tasks/T-006.md
- docs/plans/T-006-plan.md

forbidden_changes:
- README.md
- examples/README.md
- CHANGELOG.md
- docs/releases/v0.5.0.md
- core/scripts/**
- scripts/test-kit.sh
- installer/**
- profiles/**
- examples/*/run-demo.sh
- docs/policies/**
- .env*
- target/**
- build/**
- dist/**
- node_modules/**
- .m2home/**
- .idea/**

commands:
- wc -l README.md examples/README.md CHANGELOG.md docs/releases/v0.5.0.md
- curl -fsSL -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/ProfessorZJH/Vibecoding-Kit/master/README.md?cachebust=20260706 | wc -l
- curl -fsSL -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/ProfessorZJH/Vibecoding-Kit/master/examples/README.md?cachebust=20260706 | wc -l
- curl -fsSL -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/ProfessorZJH/Vibecoding-Kit/master/CHANGELOG.md?cachebust=20260706 | wc -l
- curl -fsSL -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/ProfessorZJH/Vibecoding-Kit/master/docs/releases/v0.5.0.md?cachebust=20260706 | wc -l
- git show origin/master:README.md | wc -l
- git show origin/master:examples/README.md | wc -l
- git show origin/master:CHANGELOG.md | wc -l
- git show origin/master:docs/releases/v0.5.0.md | wc -l
- git ls-tree origin/master README.md examples/README.md CHANGELOG.md docs/releases/v0.5.0.md

expected:
- README.md is 216 lines locally and on remote raw
- examples/README.md is 10 lines locally and on remote raw
- CHANGELOG.md is 51 lines locally and on remote raw
- docs/releases/v0.5.0.md is 52 lines locally and on remote raw
- README and examples index still list all four demo commands
- no README, examples index, changelog, or release note rewrite is required

commit:
- required
