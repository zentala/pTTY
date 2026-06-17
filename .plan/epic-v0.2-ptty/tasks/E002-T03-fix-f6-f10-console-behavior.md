---
id: E002-T03
title: Fix F6-F10 console behavior
status: completed
priority: critical
effort: medium
type: bug
dependencies: [E002-T01]
tags: [tmux, sessions, runtime, release-blocker]
epic: E002
branch: feat/E002-T03-f6-f10-console-behavior
group: epic-v0.2-ptty
created: 2026-06-15
completed_at: 2026-06-18
---
# E002-T03: Fix F6-F10 console behavior

## Objective

Make F6-F10 behavior match the product decision before release. Either implement
lazy creation for slots 6-10 or switch the product model to always-created 10
consoles and update docs/tests accordingly.

## Acceptance Criteria

- [x] A single product model is chosen: lazy F6-F10 or always-created F1-F10.
- [x] `src/setup.sh`, `src/tmux.conf`, status bar copy, README, and release notes agree.
- [x] First use of `Ctrl+F6` through `Ctrl+F10` does not fail.
- [x] Docker and CI tests no longer expect stale counts such as 7 sessions.

## Tests

- Fresh install, then verify F1-F10 all switch or create as documented.
- `tmux ls` expectations match the chosen model.
- Status bar remains understandable on 80 columns.

## Notes

Task 019 recommends always creating 10 consoles. If that decision is accepted,
this task should supersede the older "5 active + 5 on-demand" copy.

Decision: v0.2 uses 10 always-created console sessions. `src/setup.sh` creates
`console-1` through `console-10`, and tests now expect 10 sessions.
