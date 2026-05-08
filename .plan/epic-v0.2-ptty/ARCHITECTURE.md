# Architecture — pTTY v0.2

**Status:** Approved (matches PRD + locked decisions)
**Last updated:** 2026-05-08

---

## A. System overview

pTTY is a **UX layer on top of tmux**. tmux is the engine (multiplexing, persistence, pane management); pTTY adds:

- Fixed slot semantics (F1–F10 = `console-1` … `console-10`)
- Popup overlays for management (F11) and help (F12)
- Plugin orchestration (TPM + resurrect + continuum + which-key) via `install.sh`
- Branding, install, lifecycle (systemd unit, uninstall)

There is **no daemon, no IPC, no custom protocol.** Every script is stateless: it reads tmux state via `tmux list-sessions`, mutates via `tmux new-session`/`kill-session`, and exits. tmux server is the only persistent process pTTY adds.

```
                          ┌──────────────────────────┐
                          │  user @ terminal client  │
                          │  (kitty, alacritty, …)   │
                          └────────────┬─────────────┘
                                       │ keystrokes
                                       ▼
                          ┌──────────────────────────┐
       PTTY_DIR/tmux.conf │      tmux server         │
       sourced at start   │  (tmux 3.2+ required)    │
                          └────────────┬─────────────┘
                                       │ run-shell + display-popup
                                       ▼
                          ┌──────────────────────────┐
                          │   pTTY scripts (bash)    │
                          │   src/{core,ui,actions,  │
                          │        lib}/             │
                          └────────────┬─────────────┘
                                       │ tmux commands
                                       ▼
                          ┌──────────────────────────┐
                          │   tmux state (sessions,  │
                          │   windows, panes)        │
                          └────────────┬─────────────┘
                                       │ saved by
                                       ▼
                          ┌──────────────────────────┐
                          │  tmux-resurrect +        │
                          │  tmux-continuum          │
                          │  (15-min auto-save)      │
                          └──────────────────────────┘
```

---

## B. File layout (target after refactor)

```
~/.ptty/                          ← PTTY_DIR (templated by install.sh)
├── tmux.conf                     ← env-var driven, no hardcoded paths
├── install.sh                    ← sed-template, TPM bootstrap, version checks
├── uninstall.sh                  ← removes everything; --purge also kills sessions
├── ptty.service                  ← systemd unit (Linux only); replaces tmux-console.service
├── README.md
├── CHANGELOG.md
│
├── src/
│   ├── core/                     ← pure logic, no tmux side-effects
│   │   ├── state.sh              ← list consoles, detect status, 5s cache (Wave 2-a)
│   │   └── slots.sh              ← F-slot allocation, "lowest free", validation
│   │
│   ├── ui/                       ← user-facing surfaces
│   │   ├── manager.sh            ← F11 popup (Wave 3)
│   │   ├── help.sh               ← F12 fallback if which-key plugin absent (Wave 4-a)
│   │   ├── status-bar.tmux       ← bottom status bar config (extracted from status-format-v4)
│   │   ├── confirm.sh            ← shared confirm dialog (used by K, r)
│   │   └── shortcuts-popup.sh    ← Ctrl+H cheat sheet (existing, just moved)
│   │
│   ├── actions/                  ← single-purpose mutating scripts (Wave 2-b)
│   │   ├── attach.sh             ← switch-client to console-N
│   │   ├── kill.sh               ← kill-session console-N (with safety check)
│   │   ├── restart.sh            ← kill + recreate (atomic via lock-file)
│   │   ├── rename.sh             ← rename window (not session — see ADR)
│   │   ├── new.sh                ← create console in lowest free F-slot
│   │   └── detach.sh             ← detach client (Ctrl+D)
│   │
│   └── lib/                      ← shared helpers (Wave 2-c)
│       ├── tmux.sh               ← typed-ish tmux command wrappers
│       ├── format.sh             ← row formatters (tab-separated, no display awk)
│       ├── ps.sh                 ← CPU% / Mem from pane_pid
│       └── log.sh                ← consistent error/info logging
│
├── plugins/                      ← TPM clones submodules here
│   ├── tpm/
│   ├── tmux-resurrect/
│   ├── tmux-continuum/
│   └── tmux-which-key/
│
├── tests/                        ← bats
│   ├── unit/
│   │   ├── state.bats
│   │   ├── slots.bats
│   │   └── format.bats
│   └── smoke/
│       ├── popup-f11.bats
│       └── popup-f12.bats
│
└── docs/                         ← user docs (separate from .plan / 02-planning / 03-architecture)
    └── (empty in v0.2; symlinked from README sections)
```

**Eliminated by this refactor:**

| Old | Replaced by |
|-----|-------------|
| `~/.vps/sessions/...` legacy paths | `${PTTY_DIR}/...` (Wave 1) |
| `manager-menu.sh` (referenced but missing) | `src/ui/manager.sh` (Wave 3) |
| `mission-control.sh` (monolith) | split: `src/core/state.sh` + `src/ui/manager.sh` + `src/actions/*.sh` |
| `help-reference.sh` + `sleep infinity` | `tmux-which-key` plugin (Wave 4-a) |
| `manager` and `help` pseudo-sessions | `display-popup -E` overlays (Wave 3, 4-a) |
| `awk '{print $3}'` row parsing | tab-separated structured rows in `lib/format.sh` (Wave 2-c) |
| `restart-session.sh` lock-file logic in mission-control | `src/actions/restart.sh` with same lock pattern |

---

## C. Process model

**Stateless scripts, one tmux server.**

- pTTY scripts never run as background processes.
- A keystroke triggers `run-shell` or `display-popup`, the script does its work, exits.
- The only "state" lives in tmux server (sessions/windows/panes).
- `tmux-continuum` is the only background-ish thing — but it runs *inside* tmux's hook system, not as a separate process.

**Caching:** `src/core/state.sh` uses a 5-second in-memory cache via tmux user options:

```sh
# Cache key: $(date +%s | head -c 9)
tmux set-option -gq @ptty_state_cache_ts "$now"
tmux set-option -gq @ptty_state_cache_data "$rows"
```

Cache is per-tmux-server, lost on tmux restart. Acceptable: cold cache fills in <50ms for 10 consoles.

**Lock files:** destructive actions (kill, restart) write a lock file in `${XDG_CACHE_HOME:-~/.cache}/ptty/locks/` to prevent concurrent operations on the same console. Lock is removed on completion or by `trap` on exit.

---

## D. Data model

### D.1 Console

A **console** is a tmux session named `console-N` where `N ∈ {1..10}`.

```
session_name: console-3
window: 1 (default name "main")
pane: 1 (default shell)
```

Slot identity is **structural** — `console-3` always means slot 3. Renaming changes the *window* name only; the session name stays. (See ADR-009 if added.)

### D.2 Console state

```
type State =
  | { kind: 'live';  uptime: number; last_cmd: string; cpu: number; mem: number }
  | { kind: 'idle';  uptime: number; last_cmd: 'bash'|'zsh'|'sh' }
  | { kind: 'sleep'; uptime: number; suspended_at: number }   // auto-suspend integration
  | { kind: 'dead';  error: string }                          // session exists but in error
  | { kind: 'slot' }                                          // no session for this F-slot
```

**Detection rules** (`src/core/state.sh`):

1. `tmux has-session -t console-N` fails → `slot`
2. `pane_pid` exists, `pane_current_command` ∈ shell list → `idle`
3. `pane_pid` exists, foreground proc ≠ shell → `live`
4. Auto-suspend marker file `${PTTY_DIR}/run/suspended/console-N` present → `sleep`
5. Session exists but `tmux list-windows` errors → `dead`

### D.3 F-slot allocation

`src/core/slots.sh` provides:
- `slots_list_free` — returns F-slots with no session
- `slots_lowest_free` — returns lowest free F-slot number, or `""` if all 10 taken
- `slots_validate <n>` — confirms `n ∈ {1..10}`

---

## E. Path universality (Wave 1)

### E.1 Mechanism

Top of `tmux.conf`:

```tmux
set-environment -g PTTY_DIR "__PTTY_DIR__"
```

`install.sh`:

```bash
PTTY_DIR="${PTTY_DIR:-$HOME/.ptty}"
mkdir -p "$PTTY_DIR"
cp -r "$REPO/." "$PTTY_DIR/"
sed -i.bak "s|__PTTY_DIR__|$PTTY_DIR|g" "$PTTY_DIR/tmux.conf"
rm "$PTTY_DIR/tmux.conf.bak"
```

All bindings use format-spec `#{PTTY_DIR}`:

```tmux
bind-key -n C-F11 display-popup -E -w 90% -h 85% \
  "#{PTTY_DIR}/src/ui/manager.sh"
```

### E.2 Dev override

```bash
PTTY_DIR=$PWD ./install.sh    # install in place from clone
```

### E.3 CI guard

GitHub Actions step + `make lint`:

```bash
if grep -rE 'vps/sessions|/.tmux-persistent-console/(?!04-tasks|02-planning|03-architecture|.plan)' --include='*.sh' --include='*.tmux' --include='*.conf' .; then
  echo "ERROR: legacy hardcoded path found"
  exit 1
fi
```

---

## F. Popup contract (F11, F12)

### F.1 Invocation

```tmux
bind-key -n C-F11 display-popup -E -w 90% -h 85% "#{PTTY_DIR}/src/ui/manager.sh"
bind-key -n C-F12 display-popup -E -w 80% -h 80% "#{PTTY_DIR}/src/ui/help.sh"
```

`-E` = close popup when command exits.

### F.2 No fallback

tmux 3.2 required. `install.sh` checks version, refuses install with copy-paste upgrade hints for Debian/Ubuntu/RHEL/macOS (per Q4 decision).

### F.3 Popup boundaries

- Popup script **must not** spawn child tmux clients (no `switch-client`, no `attach-session`).
- To switch clients, popup exits with a sentinel exit code; outer keybinding chain reads it. Pattern:
  ```tmux
  bind-key -n C-F11 run-shell "#{PTTY_DIR}/src/ui/manager.sh && \
    tmux switch-client -t \"$(cat ${XDG_CACHE_HOME:-~/.cache}/ptty/last-pick)\" 2>/dev/null"
  ```
  *(actual mechanism may differ — see Wave 3 spec)*
- Popup never modifies tmux server state directly except via `src/actions/*.sh` calls.

---

## G. Plugin stack (Wave 4-b)

### G.1 Adopted plugins

| Plugin | Why | Loaded how |
|--------|-----|------------|
| TPM (`tmux-plugins/tpm`) | Plugin manager | `run "${PTTY_DIR}/plugins/tpm/tpm"` at end of `tmux.conf` |
| `tmux-resurrect` | Save/restore session layout, pane CWDs, window titles | TPM |
| `tmux-continuum` | Auto-save resurrect every 15 min, auto-restore on tmux start | TPM |
| `tmux-which-key` | F12 popup help, auto-generated from bindings | TPM |

### G.2 Why not others (decision in ADR-006)

- `tmux-sessionx` — overlaps with own F11 (rejected per Q2 hybrid decision).
- `tmux-fzf` — overlaps with F11.
- `tmux-menus` — overlaps with which-key.
- `extrakto`, `tmux-thumbs` — out of scope; user can add post-install.

### G.3 Install ordering

`install.sh`:

1. Pre-flight (tmux ≥ 3.2, fzf ≥ 0.30, git, bash 4+)
2. Copy + template `PTTY_DIR`
3. Clone TPM into `${PTTY_DIR}/plugins/tpm`
4. tmux start with new conf
5. Trigger `${PTTY_DIR}/plugins/tpm/bin/install_plugins`
6. systemd unit (Linux) — install + enable

---

## H. Persistence model

### H.1 SSH disconnect

tmux survives by default. pTTY adds nothing here.

### H.2 Host reboot

- `ptty.service` (systemd) starts tmux server on boot, attaching to a detached session.
- `tmux-continuum` saves state every 15 min; on tmux server start, it auto-restores from latest save.
- Save data lives at `${XDG_DATA_HOME:-$HOME/.local/share}/ptty/resurrect/` — **outside `$PTTY_DIR`** so `uninstall.sh` does not destroy user history. (Updated per DX review X3, 2026-05-08.)
- Result: F1–F10 windows + CWDs return after reboot. **Process state inside panes does not** (this is a tmux-resurrect limitation; we don't replay history).

### H.3 What's lost on reboot

- Running foreground processes (vim, ssh, dev servers) — by design; resurrect doesn't checkpoint process state.
- Scrollback buffer — by design; tmux doesn't persist scrollback.

This is the same trade-off as VS Code restoring open files but not running debuggers. It is the *floor* of "persistence", not the ceiling. Documented in README.

---

## I. Error handling philosophy

- **Atomic actions or no-op.** A killed restart partway through must not leave a half-dead session. `src/actions/restart.sh` uses lock + `trap EXIT` cleanup.
- **No silent failures.** Every failed action writes to `${XDG_CACHE_HOME:-~/.cache}/ptty/log` with timestamp. Manager popup shows last 3 errors at bottom if any.
- **Boundary validation only.** Internal functions trust their callers (per project guideline "trust internal code"). Validation lives at the keystroke entry point and at install-time pre-flight.

---

## J. Testing strategy (links to existing doc)

`03-architecture/testing-strategy.md` already specifies the test pyramid (50/30/15/5 unit/integration/smoke/manual). v0.2 minimum:

- `tests/unit/state.bats` — slot allocation, status detection
- `tests/unit/format.bats` — row formatting
- `tests/smoke/popup-f11.bats` — `tmux send-keys C-F11`, capture-pane, assert "pTTY Manager" header
- `tests/smoke/popup-f12.bats` — same for help
- CI matrix: tmux 3.2 / 3.5 / latest on Ubuntu 22.04 + 24.04

Bats infrastructure delivered in Wave 5 (Task 004 from existing backlog).

---

## K. ADRs

Cross-cutting decisions written as ADRs in `03-architecture/decisions/`:

- **ADR-006** — Plugin stack (resurrect + continuum + which-key, reject sessionx) — Wave 4-b
- **ADR-007** — Popup over pseudo-session (display-popup -E, drop `manager`/`help` sessions) — Wave 3
- **ADR-008** — `PTTY_DIR` env-var pattern (vs. symlink, vs. config file) — Wave 1
- **ADR-009** *(if needed)* — Slot identity vs. window name on rename

---

## L. Out of scope for v0.2 architecture

- Multi-host federation
- Daemon process (would change everything; keep stateless)
- Custom RPC protocol (we use tmux as RPC bus)
- Web UI / dashboard
- Mobile / touch UI
- Telemetry / phone-home
- Auto-update mechanism (user pulls + reruns install.sh)

---

## M. v1.0 evolution path

The modular structure (`src/{core,ui,actions,lib}`) is designed so each component can be replaced independently in a future Go rewrite (Task 017):

1. Phase A: rewrite `src/core/state.sh` → `ptty-state` Go binary, called from bash glue.
2. Phase B: rewrite actions one at a time.
3. Phase C: rewrite UI in bubbletea, replace `display-popup` invocation with `ptty manager`.
4. Phase D: drop bash entirely, single static binary.

This is **not** v0.2 work. Mentioned here so v0.2 module boundaries don't paint v1.0 into a corner.
