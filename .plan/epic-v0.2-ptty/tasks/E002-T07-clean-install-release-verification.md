---
id: E002-T07
title: Clean install release verification
status: blocked
priority: critical
effort: medium
type: chore
dependencies: [E002-T06]
tags: [qa, release, clean-install]
epic: E002
branch: feat/E002-T07-release-verification
group: epic-v0.2-ptty
created: 2026-06-15
completed_at: null
---
# E002-T07: Clean install release verification

## Objective

Verify the release on clean environments and update `.plan/REVIEW.md` with the
final release decision.

## Acceptance Criteria

- [ ] Clean curl install passes on a fresh Linux host or container.
- [ ] Local clone install passes on a fresh workspace.
- [ ] Offline artifact install is verified if release artifacts are generated.
- [ ] `scripts/doctor.sh` exits 0 after install.
- [ ] README-advertised keybindings are verified: F1-F10, F11, F12, Ctrl+H, Ctrl+R, Ctrl+Alt+R.
- [ ] `.plan/REVIEW.md` is updated with dated GO or remaining NO-GO rationale.

## Tests

- Clean install transcript or CI logs attached in this epic's journal.
- `scripts/doctor.sh`
- Manual tmux keybinding smoke test.

## Notes

This task is the release gate. Do not tag v0.2 until it is complete.

Blocked locally on 2026-06-18:

- `bash` resolves to WindowsApps/WSL and fails with `E_ACCESSDENIED`.
- `tmux` and `shellcheck` are not installed locally outside WSL.
- Docker CLI exists, but Docker Desktop's Linux engine pipe is unavailable.

Run this task in CI or on a clean Linux host/container before changing
`.plan/REVIEW.md` to GO.
