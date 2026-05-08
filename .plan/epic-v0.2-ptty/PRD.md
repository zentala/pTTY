# Product Requirements Document — pTTY v0.2

**Status:** Approved (decisions Q1–Q5 locked, see `mockups/decisions.html`)
**Owner:** zentala
**Last updated:** 2026-05-08
**Linked epic:** `.plan/v0.2-ptty-launch-epic.md`

---

## 1. Problem

Long-running terminal work over SSH dies when the network blips, the laptop sleeps, or the host reboots. tmux fixes the persistence problem but ships a developer-grade UI: prefix keys, manual session names, no overview of what's running where. The cognitive load is non-trivial: users either learn `Ctrl+B :new-session -s foo` muscle memory, or they don't use it.

We want **persistent terminal sessions with a real UI**: numbered console slots (F1–F10), one-key navigation, a popup overview of all sessions with live metrics, automatic recovery across host reboots — without users learning tmux.

## 2. Users

| Persona | Context | Pain | What they need |
|---------|---------|------|----------------|
| **Primary: SSH power user** | Engineer on laptop SSH'd into a homelab / VPS / dev box | "My session died when WiFi dropped" / "I forgot which tmux window had the build" | Persistent, numbered slots, visual overview |
| **Secondary: Selfhost hobbyist** | Runs Proxmox / homelab, manages 5–20 services from terminal | Juggles 6+ ad-hoc tmux sessions, loses track | One panel showing all consoles + uptime + last command |
| **Tertiary: Pair / handoff** | Shares a server account with teammate / another machine | Reattach to existing work without coordination | Fixed slot semantics (F1 = build, F2 = logs) so attach is predictable |

Out-of-persona: dev who lives in `tmux` / `screen` purist already and doesn't want a UI. They're not the customer.

## 3. Goals

### 3.1 Primary
- **G1.** Pressing F1–F10 jumps to console N. Always works. Empty slots auto-create.
- **G2.** F11 opens a popup with all consoles, status, metrics, single-key actions (switch, kill, restart, rename, new).
- **G3.** F12 opens a discoverable help popup auto-rendered from current bindings.
- **G4.** Sessions survive: SSH disconnect, host reboot, terminal crash.
- **G5.** Install is one command, takes <60s on a clean Debian/Ubuntu/macOS.

### 3.2 Secondary
- **G6.** First-time user discovers all features within 60 seconds via F12 + status bar hints.
- **G7.** Project ships under the name **pTTY** with brand consistency across repo, docs, popups, web.
- **G8.** Codebase is modular enough that a v1.0 Go rewrite can replace one component at a time.

### 3.3 Non-goals
- ✗ Replace tmux as the engine (we're a UX layer on top)
- ✗ Cross-host federation
- ✗ Web dashboard
- ✗ Custom shell or multiplexer protocol
- ✗ Mobile / touch UI

## 4. Functional requirements

### FR-1 · Console slots
- 10 fixed slots: `console-1` … `console-10`, mapped to F1–F10
- F1–F5 created on boot (eager); F6–F10 lazy-create on first press
- Slot identity is permanent — `console-3` always means slot 3
- A console can be: **live** (active processes), **idle** (no foreground proc), **sleep** (auto-suspended), **dead** (crashed), **slot** (no session yet)

### FR-2 · F11 Manager popup
- Trigger: `Ctrl+F11` (raw F11 reserved for terminal full-screen on most clients)
- Render: tmux `display-popup -E -w 90% -h 85%`
- Columns: F-key · Status · Console · Uptime · Last cmd · CPU% · Mem
- Single-key actions: `Enter` switch, `K` kill (confirm), `r` restart (confirm), `R` rename inline, `n` new (lowest free slot), `j/k` move, `1-0` jump cursor, `/` filter, `?` help, `q/Esc` close
- Live preview pane shows current pane content of selected console
- Refresh after every mutating action
- Closing returns to previous client state (no `manager` pseudo-session)

### FR-3 · F12 Help popup
- Trigger: `Ctrl+F12`
- Render: tmux `display-popup -E -w 80% -h 80%`
- Adopts `alberti42/tmux-which-key` plugin
- Bindings auto-generated from `tmux list-keys` + structured comments (`# @group: nav @desc: ...`) in `tmux.conf`
- Search (`/`), regroup (`g`), close (`q`/`Esc`/`F12`)
- Toggle behavior: pressing F12 while open closes it

### FR-4 · Install
- One-liner: `curl -sSL https://ptty.zentala.io/install | bash`
- Default install dir: `~/.ptty` (override: `PTTY_DIR=/path ./install.sh`)
- `tmux.conf` is templated via `sed` from a placeholder
- TPM + plugins (resurrect, continuum, which-key) auto-installed
- Idempotent: re-running upgrades cleanly
- Pre-flight checks: tmux ≥ 3.2, fzf ≥ 0.30; refuse with copy-paste upgrade hints

### FR-5 · Uninstall
- `bash ~/.ptty/uninstall.sh` removes everything
- Sessions kept by default; `--purge` kills them too
- Restores backup of pre-existing `~/.tmux.conf` if any

### FR-6 · Persistence across reboot
- `tmux-resurrect` saves layout / windows / pane CWDs
- `tmux-continuum` auto-saves every 15 min, auto-restores on tmux start
- `ptty.service` (systemd, Linux only) starts tmux server on boot

### FR-7 · Status bar
- Shows F1–F10 as tabs with live status icons
- Active tab highlighted
- Click-to-switch (mouse mode on)
- Doesn't break on 80-column width

### FR-8 · Migration from legacy install
- Detects `~/.vps/sessions/` or `~/.tmux-persistent-console/` from prior installs
- Symlinks the legacy path to `~/.ptty` for one release cycle
- Prints a migration notice on first run

## 5. Non-functional requirements

| ID | Requirement | Measurable target |
|----|-------------|-------------------|
| NFR-1 | F11 popup opens fast | <150ms from keypress to render on a warm cache |
| NFR-2 | State refresh is cheap | ≤ 50ms for 10-console state read (pid + ps + tmux info), 5s in-memory cache |
| NFR-3 | Install completes quickly | <60s on a clean VM with broadband |
| NFR-4 | tmux compatibility | tmux 3.2+ (popup mandatory) |
| NFR-5 | Shell compatibility | bash 4+; install.sh POSIX-sh-clean |
| NFR-6 | OS compatibility | Linux (Debian 12+, Ubuntu 22.04+, RHEL 9+) — full systemd autostart; macOS 12+ — manual shell-rc autostart, LaunchAgent in v0.3 (per DX review X5) |
| NFR-7 | No daemon | All scripts stateless; tmux server is the only persistent process we add |
| NFR-8 | Failure mode | Any subscript failure leaves tmux state untouched (atomic actions or no-op) |
| NFR-9 | Localization | English UI in v0.2; structure ready for i18n in v0.3 |
| NFR-10 | Accessibility | Works in screen readers via plain-text rendering (no ANSI tricks that break TTS) |

## 6. Success metrics

| Metric | v0.2 target | How measured |
|--------|-------------|--------------|
| Install success rate on clean VM | >95% | CI matrix (Debian 12, Ubuntu 24.04, macOS 14) |
| Time from install to first F11 popup | <90s | Manual timing on demo recording |
| GitHub stars 30 days after release | 100+ | github.com/zentala/ptty |
| Reported install failures | <5 issues in first 30 days | GitHub Issues |
| Reattach success after host reboot | 100% (with continuum) | bats integration test |
| Documentation completeness | 0 open "how do I" issues unanswered by README+F12 | Issue triage |

## 7. Constraints

- **Bash + fzf, no Go in v0.2.** Go rewrite (Task 017) is v1.0.
- **Single-user.** No multi-tenant, no permission system.
- **Local only.** No network protocols, no telemetry, no auto-update phone-home.
- **GPL/MIT-compatible deps only.** TPM, fzf, which-key, resurrect, continuum all OK.
- **Maintainer-of-one.** Every feature has to be maintainable by one person; this kills "smart" behaviors.

## 8. Dependencies

| Dep | Purpose | Version | License |
|-----|---------|---------|---------|
| tmux | Multiplexer engine | ≥ 3.2 | ISC |
| fzf | F11 list + filter | ≥ 0.30 | MIT |
| TPM | Plugin manager | latest | MIT |
| tmux-resurrect | Save sessions | latest | MIT |
| tmux-continuum | Auto-save scheduler | latest | MIT |
| tmux-which-key | F12 help | latest | MIT |
| bash | Scripts | ≥ 4.0 | GPL |
| ps / coreutils | Metrics | POSIX | GPL |
| systemd (Linux) | Boot autostart | optional | LGPL |

## 9. Risks (selected — full register in epic)

- Plugin upstream goes unmaintained → fork or replace
- tmux 4.0 breaks `display-popup` semantics → version-pin our compat
- Single-key destructive (`K`) accidentally fires → confirm dialog default Cancel + ADR-007
- README GIFs slip release → Phase 5 explicitly allocates time, use `vhs` for reproducibility

## 10. Open questions (post-decisions)

These were not in Q1–Q5 and may surface in implementation:
- **Q-A.** Should `n` (new) prompt for slot or auto-pick lowest free? *Default: auto-pick; users can drag-reorder later.*
- **Q-B.** Should F11 show stopped containers (auto-sleep wake-up state)? *Out of scope for tmux-only product; revisit if pTTY learns about Docker.*
- **Q-C.** Should rename (`R`) update the slot label or just window name? *Window name only; slot identity is structural.*

## 11. References

- Epic: `.plan/v0.2-ptty-launch-epic.md`
- Decisions: `02-planning/mockups/decisions.html`
- F11/F12 mockup: `02-planning/mockups/f11-f12-redesign.html`
- Specs: `02-planning/v0.2/specs/`
- Architecture: `03-architecture/v0.2/`
- ADRs: `03-architecture/decisions/adr-006`, `adr-007`, `adr-008`
- Tasks: `04-tasks/012`–`017`, `001`–`005`
