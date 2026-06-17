# v0.2 Pre-Release Blockers Orchestrator

**Epic:** pTTY v0.2 Launch
**Created:** 2026-06-15
**Source review:** [../REVIEW.md](../REVIEW.md)
**Status:** Implemented through Wave D; final clean-install verification blocked locally

## Execution Order

Wave A is already represented by GitHub PR #1 and should land first. Waves B-D
must stay gated because each one changes user-facing release claims or runtime
behavior that later verification depends on.

## Wave A - Land Existing Installer Fix

- [x] [E002-T01](tasks/E002-T01-merge-remote-installer-pr.md) - Merge PR #1 and clean stale install URLs.

## Wave B - Runtime Release Blockers

- [x] [E002-T02](tasks/E002-T02-fix-f11-manager-binding.md) - Fix the F11 manager binding and shipped script name mismatch.
- [x] [E002-T03](tasks/E002-T03-fix-f6-f10-console-behavior.md) - Make F6-F10 behavior match the chosen product model.

## Wave C - Release Truthfulness and Agent Context

- [x] [E002-T04](tasks/E002-T04-remove-reboot-persistence-claims.md) - Remove misleading server-reboot persistence claims.
- [x] [E002-T05](tasks/E002-T05-repair-readme-claude-pm-state.md) - Repair README, Claude guidance, and PM status drift.

## Wave D - Gates and Verification

- [x] [E002-T06](tasks/E002-T06-harden-ci-release-gates.md) - Make CI catch installer, tmux config, shell, and docs regressions.
- [ ] [E002-T07](tasks/E002-T07-clean-install-release-verification.md) - Run clean-install release verification and update release decision.

## Dependency Graph

```text
E002-T01
  -> E002-T02
  -> E002-T03
       -> E002-T04
       -> E002-T05
            -> E002-T06
                 -> E002-T07
```

## Current Release Gate

Do not publish a release until E002-T07 is completed:

- Clean curl install passes on a fresh Linux host.
- Every README-advertised keybinding is verified.
- F1-F10, F11, and F12 behavior matches README and `CLAUDE.md`.
- No user-facing docs claim in-memory sessions survive server reboot.
- CI fails on ShellCheck, tmux config parse, installer file coverage, and markdown link errors.
- `.plan/REVIEW.md` is updated from NO-GO to a dated release decision.

## Local Verification Blocker

Implementation work is complete through E002-T06, but E002-T07 could not be
completed on this Windows machine:

- `bash` resolves to WindowsApps/WSL and exits with `E_ACCESSDENIED`.
- `tmux` and `shellcheck` are not installed locally outside WSL.
- Docker CLI is installed, but Docker Desktop's Linux engine pipe is not running.
