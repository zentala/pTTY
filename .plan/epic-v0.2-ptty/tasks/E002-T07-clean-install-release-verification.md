---
id: E002-T07
title: Clean install release verification
status: completed
priority: critical
effort: medium
type: chore
dependencies: [E002-T06]
tags: [qa, release, clean-install]
epic: E002
branch: feat/E002-T07-release-verification
group: epic-v0.2-ptty
created: 2026-06-15
completed_at: 2026-06-18
---
# E002-T07: Clean install release verification

## Objective

Verify the release on clean environments and update `.plan/REVIEW.md` with the
final release decision.

## Acceptance Criteria

- [x] Clean install passes in a fresh Ubuntu 24.04 Docker environment.
- [x] Local clone install passes through `bash install.sh` in Docker.
- [x] Offline artifact install is not applicable before release artifacts are generated.
- [x] `scripts/doctor.sh` exits 0 after install in CI/container mode.
- [x] README-advertised keybinding definitions are verified by tmux config parse and reference checks.
- [x] `.plan/REVIEW.md` is updated with a dated GO rationale.

## Tests

- GitHub Actions PR #2 Docker-based Testing.
- GitHub Actions PR #2 Quick Validation.
- `scripts/doctor.sh` in Docker build for `testuser` and `devuser`.
- tmux config parse and tmux reference coverage checks.

## Notes

This task was completed in CI because local Windows tooling could not run the
Linux release gates. Physical terminal keypress smoke was not performed
locally; keybinding definitions were validated through tmux config parsing and
reference checks.
