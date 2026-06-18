# CLAUDE.md - AI Assistant Guidelines

This file gives Claude Code and other AI agents the current operating context
for this repository.

## Current Release State

- Product: pTTY, an opinionated tmux preset for persistent AI coding terminals.
- Current milestone: v0.2 pre-release hardening.
- Release gate: follow `.plan/REVIEW.md` and `.plan/epic-v0.2-ptty/ORCHESTRATOR.md`.
- Do not tag a release while `.plan/REVIEW.md` says `NO-GO`.

## Product Contract

pTTY protects long-running terminal processes from client-side disruption:

- SSH disconnects
- WiFi/VPN/network changes
- laptop sleep
- client reboot
- accidental `exit` in the wrong tmux session

pTTY does not preserve in-memory AI context across a server reboot. The systemd
user service can recreate empty sessions after boot, but the old tmux server,
scrollback, running processes, and AI conversation state are gone.

## F-Key Model

- `Ctrl+F1`-`Ctrl+F10`: switch to `console-1` through `console-10`.
- `Ctrl+F11`: open the Manager Menu from `src/mission-control.sh`.
- `Ctrl+F12`: open the Help Reference from `src/help-reference.sh`.
- Never describe `Ctrl+F1`-`Ctrl+F12` as console switching. F11 and F12 are tools.
- v0.2 uses 10 always-created console sessions. Do not reintroduce the old
  "5 active + 5 on-demand" or "suspended console" model.

## Source of Truth

- Product/spec: `02-planning/SPEC.md`
- Architecture: `03-architecture/ARCHITECTURE.md`
- Naming: `03-architecture/NAMING.md`
- Icons: `docs/ICONS-NETWORK-SET.md`
- Release review: `.plan/REVIEW.md`
- Epic execution: `.plan/epic-v0.2-ptty/ORCHESTRATOR.md`

If these files disagree, update the release review and epic task notes before
changing behavior.

## Installer Facts

- Public install URL:
  `https://raw.githubusercontent.com/zentala/pTTY/main/install.sh`
- Default install directory remains `~/.tmux-persistent-console` for this
  release. Do not rename it to `~/.ptty` unless the rename task is explicitly in
  scope.
- `src/tmux.conf` references installed files under `~/.tmux-persistent-console`.
  Any new referenced file must be included in the remote download list in
  `install.sh`.

## Development Rules

- Read existing scripts before editing; keep shell changes small and portable.
- Prefer tmux native formats in status bar code. Do not add periodic external
  scripts to the status bar.
- Keep user-facing docs honest about server reboot behavior.
- Keep repo docs in English.
- Use Conventional Commits if committing.
- Do not revert unrelated local changes in `.plan/BACKLOG.md` or `.plan/reports/`.

## Local Validation

Run the relevant subset before marking work complete:

```bash
bash -n install.sh
for script in src/*.sh tools/*.sh tests/scripts/*.sh; do bash -n "$script"; done
bash tools/check-tmux-references.sh
bash tools/check-markdown-links.sh README.md CLAUDE.md
```

On Linux with tmux available, also run:

```bash
tmux -f src/tmux.conf start-server \; source-file src/tmux.conf \; list-keys
tests/docker/test-local.sh test
```
