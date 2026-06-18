# Pre-Release Review

**Date:** 2026-06-18
**Scope:** pTTY v0.2 release readiness after E002 implementation.
**Conclusion:** GO for merging PR #2 and preparing the v0.2 release candidate.

---

## Release Decision

**Recommendation:** GO for merging the release-blocker branch.

The previously identified implementation blockers have been addressed and
verified by GitHub Actions on PR #2. Docker-based testing now exercises the
local installer path for both test users, runs `scripts/doctor.sh` in CI mode,
verifies 10 sessions, verifies multi-user setup, and checks SSH shortcut
configuration.

Tagging v0.2 should still happen through the normal release workflow, but this
branch no longer has a release-blocking finding.

## Implemented Since Initial Review

1. **Remote installer cleanup**
   - PR #1 was merged as `384f85ff70cc8a590c2e9e5d65f11827e6dade53`.
   - `install.sh` header/help now use `zentala/pTTY`.
   - `tools/check-tmux-references.sh` verifies files referenced by
     `src/tmux.conf` exist in `src/` and are included in the installer.

2. **F11 manager binding**
   - `Ctrl+F11` now opens `mission-control.sh` via `display-popup`.
   - Removed the stale `manager-menu.sh` binding.
   - CI checks prevent missing tmux binding targets from silently shipping.

3. **F1-F10 product model**
   - v0.2 now uses 10 always-created consoles.
   - `src/setup.sh` creates `console-1` through `console-10`.
   - `src/tmux.conf`, status bar copy, README, Claude guidance, Docker tests,
     remote tests, and release notes were aligned.

4. **Reboot persistence claims**
   - Public copy no longer claims in-memory sessions survive server reboot.
   - Correct contract: sessions survive SSH/client disconnects; after server
     reboot the service can recreate empty sessions.

5. **README, Claude, and PM drift**
   - README links now point to existing paths such as `02-planning/SPEC.md` and
     `03-architecture/ARCHITECTURE.md`.
   - Root `CLAUDE.md` was rewritten into concise current guidance.
   - `04-tasks/TODO.md` now has one current release state.
   - Tracked `.claude/settings.local.json` was removed from git tracking and
     ignored.
   - Obsolete `src/*old-backup.sh` scripts were removed.

6. **CI gates**
   - ShellCheck failures are blocking for release-relevant scripts.
   - tmux config parse failures are blocking.
   - Markdown link checking covers README and CLAUDE.md.
   - Docker/session-count assertions expect 10 sessions.

## Closed Release Gate

### E002-T07: Clean install release verification

Completed through GitHub Actions on PR #2:

- Docker clean-install test passed on Ubuntu 24.04 containers.
- Docker server image installs via `bash install.sh` from a local checkout.
- `scripts/doctor.sh` runs after install for both `testuser` and `devuser`.
- Automated Docker tests verify SSH connectivity, 10 sessions, `console-1` and
  `console-10`, multi-user setup, and configured SSH shortcuts.
- Quick Validation parses `src/tmux.conf`, validates tmux reference coverage,
  runs ShellCheck, validates shell syntax, validates Markdown links, and runs
  Terraform validation.
- Keybinding definitions are verified by tmux config parse and reference
  checks for the README-advertised bindings. Physical terminal keypress smoke
  was not performed in this Windows environment.

## Remaining Improvements

Tracked in `.plan/epic-v0.2-ptty/IMPROVEMENTS.md`:

- Verify actual minimum supported tmux version.
- Add offline release artifact verification.

## Local Verification Performed

PowerShell equivalents passed:

- `src/tmux.conf` referenced files all exist in `src/`.
- Every `src/tmux.conf` referenced file appears in `install.sh`.
- `src/tmux.conf` no longer references `manager-menu.sh`.
- Relative markdown links in `README.md` and `CLAUDE.md` resolve locally.

Not run locally:

- `bash -n`
- ShellCheck
- tmux config parse
- Docker clean install

Reason: local toolchain/environment blockers listed above. These checks were
run in GitHub Actions instead.
