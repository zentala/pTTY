---
id: E002-T02
title: Fix F11 manager binding
status: completed
priority: critical
effort: small
type: bug
dependencies: [E002-T01]
tags: [tmux, runtime, manager, release-blocker]
epic: E002
branch: feat/E002-T02-f11-manager-binding
group: epic-v0.2-ptty
created: 2026-06-15
completed_at: 2026-06-18
---
# E002-T02: Fix F11 manager binding

## Objective

Make `Ctrl+F11` work after install by resolving the mismatch between
`src/tmux.conf` and the manager script shipped in `src/`.

## Acceptance Criteria

- [x] `src/tmux.conf` references a manager script that exists after both local clone install and remote curl install.
- [x] The chosen script name is documented consistently in README and Claude guidance.
- [x] F11 opens a manager UI or a clearly scoped fallback without creating a broken pseudo-session.
- [x] `scripts/doctor.sh` or CI can detect missing tmux binding targets.

## Tests

- Parse `src/tmux.conf` and assert referenced script files exist in `src/`.
- Manual or automated tmux smoke test for `Ctrl+F11` on a clean install.

## Notes

Current mismatch: `src/tmux.conf` calls `manager-menu.sh`; repo contains
`mission-control.sh`.

Resolved by binding `Ctrl+F11` to `mission-control.sh` via `display-popup` and
adding `tools/check-tmux-references.sh` to CI.
