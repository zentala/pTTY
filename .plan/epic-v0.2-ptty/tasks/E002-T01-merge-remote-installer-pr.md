---
id: E002-T01
title: Merge remote installer PR
status: completed
priority: critical
effort: small
type: bug
dependencies: []
tags: [installer, github, release-blocker]
epic: E002
branch: fix/remote-install-missing-files
group: epic-v0.2-ptty
created: 2026-06-15
completed_at: 2026-06-18
---
# E002-T01: Merge remote installer PR

## Objective

Land GitHub PR #1, which fixes the remote curl installer source URL and adds
the missing `src/` files required by `src/tmux.conf`.

## Acceptance Criteria

- [x] PR #1 is merged to `main`.
- [x] `install.sh` header and `--help` curl examples point at `zentala/pTTY`.
- [x] The remote download file list includes every non-backup file referenced by `src/tmux.conf`.
- [x] Existing local planning/report files are not reverted or overwritten.

## Tests

- `gh pr checks 1`
- `git show --stat --oneline HEAD`
- Follow-up clean install verification is covered by E002-T07.

## Notes

This task resolves the first critical finding in `.plan/REVIEW.md`, but it does
not resolve the F11 manager binding, F6-F10 behavior, docs, or CI gates.

PR #1 was merged on 2026-06-15 as merge commit
`384f85ff70cc8a590c2e9e5d65f11827e6dade53`. The stale install URL examples in
`install.sh` were corrected on 2026-06-18.
