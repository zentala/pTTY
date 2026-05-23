---
name: BACKLOG
description: Pre-epic ideas for pTTY — things worth doing but not scoped to a current epic yet
updated: 2026-05-23
---

# pTTY BACKLOG

Loose ideas that haven't been promoted to an epic yet. When something here gets picked up,
move it into `.plan/epic-<version>-*/` with proper PLAN.md + tasks.

---

## Installer / Daemon UX

### [ ] `ptty daemonize` CLI command

- **Idea**: explicit user-facing command to manage the tmux daemon lifecycle.
  Today `install.sh` enables systemd+linger by default, which is the right default
  (see CLAUDE.md rule #8) — but there's no neutral user-facing verb for "start the
  daemon" / "ensure it's running" / "check if it's running". `ptty daemonize` would
  be that command.
- **Why**: discoverable. A user who skipped systemd at install time (planned
  `--no-systemd` flag, see below) still needs a way to manually bring the daemon
  up without copy-pasting `systemctl --user start ...` from docs.
- **Scope sketch**:
  - `ptty daemonize` — start tmux daemon if not running (idempotent)
  - `ptty daemonize --status` — report running/not-running + uptime
  - `ptty daemonize --enable-boot` — opt back into systemd autostart later
  - `ptty daemonize --disable-boot` — opt out of systemd autostart
- **Note**: currently pTTY does NOT do any explicit daemonize step. tmux just gets
  spawned on first session creation. This command would formalize the lifecycle
  into something users (and the README) can talk about.
- **Not urgent**: autostart-by-default covers the 95% case. This is for power users
  and for honesty in docs.

### [ ] `install.sh --no-systemd` opt-out flag

- **Idea**: let users decline the systemd autostart at install time, either via
  `--no-systemd` flag or an interactive prompt.
- **Why**: CLAUDE.md rule #8 mentions opt-out as a planned escape hatch. Some
  users (shared hosts, restricted environments, anti-systemd preference) won't
  want linger enabled.
- **Default stays autostart-on** (per user decision 2026-05-23). This is opt-out,
  not opt-in.

---

## Docs / Marketing

### [ ] Reshoot hero screenshot with `you@server.lan`

- **Current**: `docs/images/ptty-console.png` shows `zentala @ server.lan` —
  documented as an accepted exception to placeholder rule #10.
- **Next reshoot**: use `you@server.lan` (cleaner generic placeholder, still looks
  natural — `.lan` suggests a real homelab context without naming a person).
- **Trigger**: next time the status bar UI changes meaningfully, or before any
  marketing push (HN, Reddit, social).
