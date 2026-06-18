# v0.2 Pre-Release Journal

## 2026-06-15

- Created `.plan/REVIEW.md` with a NO-GO release decision based on installer,
  runtime, docs, Claude configuration, PM status, and CI gaps.
- Found open GitHub PR #1, `fix(install): add missing src files to remote
  download + fix repo URL`. It addresses the remote curl installer file
  coverage blocker, but does not address F11, F6-F10, persistence claims, docs,
  or CI gates.
- Added task breakdown for remaining pre-release blockers under
  `.plan/epic-v0.2-ptty/tasks/`.
- Merged GitHub PR #1 into `main` with merge commit
  `384f85ff70cc8a590c2e9e5d65f11827e6dade53`. The PR fixes the remote
  installer download list and repository base URL. Follow-up remains in
  E002-T01 for stale user-facing install URL examples in `install.sh`.

## 2026-06-18

- Implemented E002-T01 through E002-T06 on branch `E002-v0.2-release-blockers`.
- Updated `install.sh`, runtime scripts, README, CLAUDE.md, Docker/cloud tests,
  and GitHub Actions to use the 10 always-created console model and the
  `zentala/pTTY` public install URL.
- Rewired `Ctrl+F11` to `mission-control.sh` and added CI checks for tmux
  reference coverage and release-facing markdown links.
- Removed tracked `.claude/settings.local.json` from git and ignored it because
  it contains local permission state.
- Removed obsolete `src/*old-backup.sh` helper scripts that preserved the old
  seven-console model.
- Local release verification remains blocked: Windows `bash` maps to WSL and
  returns `E_ACCESSDENIED`; `tmux` and `shellcheck` are unavailable; Docker
  Desktop's Linux engine is not running.
- Closed E002-T07 through GitHub Actions on PR #2. Docker-based testing now
  installs via `bash install.sh`, runs `scripts/doctor.sh` for both Docker test
  users, verifies 10 sessions, checks multi-user setup, and exercises SSH
  shortcut configuration.
- Updated `.plan/REVIEW.md` from NO-GO to GO for merging PR #2 and preparing
  the v0.2 release candidate. Local Windows WSL remains unavailable, but CI
  provides the Linux/tmux/Docker release gate.
