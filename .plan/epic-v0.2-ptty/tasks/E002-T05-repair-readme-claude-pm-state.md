---
id: E002-T05
title: Repair README Claude and PM state
status: completed
priority: high
effort: medium
type: docs
dependencies: [E002-T04]
tags: [docs, claude, pm, release-blocker]
epic: E002
branch: feat/E002-T05-docs-claude-pm
group: epic-v0.2-ptty
created: 2026-06-15
completed_at: 2026-06-18
---
# E002-T05: Repair README Claude and PM state

## Objective

Remove stale links and contradictory status from README, Claude context, and PM
files so agents and users see one current release story.

## Acceptance Criteria

- [x] README no longer says `Ctrl+F1`-`F12` all switch consoles.
- [x] README links point to existing files such as `02-planning/SPEC.md` and `03-architecture/ARCHITECTURE.md`.
- [x] Root `CLAUDE.md` is concise, current, and executable.
- [x] `04-tasks/TODO.md` has one current quality-gate state, not both PAUSED and GO.
- [x] `.plan/REVIEW.md` and this epic reference each other.

## Tests

- Markdown link check for README and Claude files.
- `rg -n "Ctrl\\+F1.*F12|\\[SPEC\\.md\\]\\(SPEC\\.md\\)|SAFE-EXIT\\.md|docs/naming|docs/ICONS\\.md|\\[ARCHITECTURE\\.md\\]\\(ARCHITECTURE\\.md\\)" README.md CLAUDE.md`

## Notes

Keep historical planning notes where useful, but mark them explicitly as
historical so future agents do not treat them as current release instructions.

Also removed obsolete backup scripts and stopped tracking local
`.claude/settings.local.json`.
