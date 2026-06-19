# v0.2 Pre-Release Improvements

**Created:** 2026-06-15
**Source:** Root pre-release review in `.plan/REVIEW.md`.

These items are not all hard release blockers, but they should be triaged before
closing the v0.2 epic.

## Open

- [x] Decide whether `.claude/settings.local.json` is intentionally shared. If not, remove it from git and add it to `.gitignore`.
- [x] Remove or archive obsolete backup scripts such as `src/console-help-old-backup.sh` and `src/help-console-old-backup.sh`.
- [x] Normalize public naming across install paths, repo URL, README, release workflow, and docs.
- [ ] Verify the actual minimum supported tmux version against the features used by `src/tmux.conf`.
- [ ] Run a visual launch review of F11 Manager and F12 Help before recording
      the promotional demo.
- [ ] Add or verify a forced fallback-icon mode so non-Nerd-Font rendering can be
      tested and optionally shown in the launch animation.
- [x] Replace README examples that use broad `tmux kill-server` commands with scoped pTTY-only commands.
- [x] Add a markdown link checker for README, Claude files, and release docs.
- [x] Add an installer file-coverage check that fails when `tmux.conf` references a file not shipped by remote install.
- [ ] Add release artifact verification for the offline installer, not only the curl installer.

## Promoted to Tasks

- [E002-T01](tasks/E002-T01-merge-remote-installer-pr.md) - Existing remote installer PR.
- [E002-T02](tasks/E002-T02-fix-f11-manager-binding.md) - F11 manager script mismatch.
- [E002-T03](tasks/E002-T03-fix-f6-f10-console-behavior.md) - F6-F10 product/runtime mismatch.
- [E002-T04](tasks/E002-T04-remove-reboot-persistence-claims.md) - Reboot persistence wording.
- [E002-T05](tasks/E002-T05-repair-readme-claude-pm-state.md) - README, Claude, and PM drift.
- [E002-T06](tasks/E002-T06-harden-ci-release-gates.md) - CI release gates.
- [E002-T07](tasks/E002-T07-clean-install-release-verification.md) - Final release verification.
