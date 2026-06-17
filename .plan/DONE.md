# Completed Tasks

## 2026-06-18

- **[E002-T01](epic-v0.2-ptty/tasks/E002-T01-merge-remote-installer-pr.md)** —
  Merged PR #1 and cleaned remaining public install URL examples in
  `install.sh`.
- **[E002-T02](epic-v0.2-ptty/tasks/E002-T02-fix-f11-manager-binding.md)** —
  Rewired `Ctrl+F11` to the shipped `mission-control.sh` manager and added a CI
  reference check for tmux binding targets.
- **[E002-T03](epic-v0.2-ptty/tasks/E002-T03-fix-f6-f10-console-behavior.md)** —
  Chose and implemented the 10 always-created console model across setup,
  tmux bindings, status bar copy, docs, Docker, and remote tests.
- **[E002-T04](epic-v0.2-ptty/tasks/E002-T04-remove-reboot-persistence-claims.md)** —
  Replaced misleading server-reboot persistence claims with the correct daemon
  autostart / empty-session recreation contract.
- **[E002-T05](epic-v0.2-ptty/tasks/E002-T05-repair-readme-claude-pm-state.md)** —
  Repaired README links and behavior copy, rewrote root `CLAUDE.md`, normalized
  current PM status, and removed tracked local Claude permission state.
- **[E002-T06](epic-v0.2-ptty/tasks/E002-T06-harden-ci-release-gates.md)** —
  Made release-relevant ShellCheck and tmux parse checks blocking in CI, added
  tmux reference coverage and markdown link checks, and aligned Docker session
  counts with the 10-console model.
