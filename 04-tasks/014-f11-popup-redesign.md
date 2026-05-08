# Task 014: F11 Manager — Popup Redesign (lazygit-style)

**Status:** 📋 BACKLOG (v0.2)
**Priority:** HIGH
**Created:** 2026-05-08
**Depends on:** Task 013 (path fix)

---

## Problem

Current F11 opens a *parallel tmux session* `manager` running fzf in two-step mode:
1. Pick session in fzf list
2. Press Enter → second prompt appears (Switch / Restart / Cancel)
3. Press another key → action

Issues:
- Pseudo-session pollutes `list-sessions`, `choose-tree`, status bar
- Two-step UX (select → confirm-action) is slow, every action takes 3+ keys
- Only Switch/Restart available — no Kill, Rename, New
- Uses `awk '{print $3}'` to parse display rows — fragile
- No metrics: uptime, last command, CPU, sleep state

## Goal

Single-screen, single-key actions, popup overlay (no pseudo-session).

## Design

### Invocation
```tmux
bind-key -n C-F11 display-popup -E -w 90% -h 85% \
  "#{PTTY_DIR}/src/mission-control.sh"
```

### Layout
```
┌─ pTTY Manager ───────────────────────────────────  [?] help  [q] close ─┐
│                                                                          │
│  F-key  Status   Console        Uptime   Last cmd          CPU%  Mem    │
│  ─────  ──────   ─────────────  ───────  ─────────────────  ────  ─────  │
│ ▸ F1    ● live   console-1      2h 14m   vim src/main.go    1.2%  84M   │
│   F2    ● live   console-2      45m      pnpm dev           18%   312M  │
│   F3    ○ idle   console-3       3m      bash               0%    12M   │
│   F4    💀 dead  console-4      —        (crashed)          —     —     │
│   F5    ● live   console-5      8h 02m   ssh prod           0.1%  6M    │
│   F6    — slot   (empty)        —        —                   —     —     │
│   ...                                                                    │
│                                                                          │
│  ─── Preview: console-1 ────────────────────────────────────────────────│
│  $ vim src/main.go                                                       │
│  ~ NORMAL ~ src/main.go     1234L, 5678C                                 │
│                                                                          │
└─ Enter switch · k kill · r restart · n new · R rename · / search ────────┘
```

### Keybindings (one key = one action)

| Key | Action |
|-----|--------|
| `j` / `↓` | move down |
| `k` / `↑` | move up |
| `Enter` | switch to selected console |
| `K` (shift-k) | kill selected (with confirm) |
| `r` | restart selected (with confirm) |
| `R` | rename selected |
| `n` | new console (auto-pick lowest free F-slot) |
| `/` | filter / search |
| `?` | help overlay |
| `q` / `Esc` | close popup |
| `1`-`9`,`0` | jump cursor to F1-F10 row |

> Note: `k` is "up" (vi-style). Kill is `K` (shift) to avoid accidents.

### Columns

- **F-key** — F1..F10 binding for that console
- **Status** — `● live` (active processes), `○ idle` (no foreground proc), `💀 dead` (session exists but errored), `— slot` (free slot, no session)
- **Console** — session name
- **Uptime** — since session creation (`tmux display -p -t S '#{session_created}'`)
- **Last cmd** — current foreground command (`pane_current_command`)
- **CPU%** / **Mem** — from `ps -o %cpu,rss -p $(tmux display -p -t S '#{pane_pid}')`

### Implementation

- Bash + fzf with `--bind` for inline actions:
  ```
  fzf --bind 'K:execute(./kill.sh {})+reload(./list.sh)' \
      --bind 'r:execute(./restart.sh {})+reload(./list.sh)' \
      --bind 'n:execute(./new.sh)+reload(./list.sh)'
  ```
- OR rewrite in `gum` for cleaner code
- OR (v1.0) rewrite in Go + bubbletea

## Acceptance

- F11 opens popup, no `manager` session in `list-sessions`
- All keybindings work, single-keystroke
- Kill/Restart show confirm dialog (default: cancel)
- New console picks lowest free F-slot, opens it
- Live refresh after every action
- Works on tmux 3.2+ (graceful degrade via Ctrl+H pattern? — no, popup mandatory)

## Out of scope

- Multi-select (v0.3)
- Move console between F-slots (v0.3)
- Cross-host sessions (v1.0)
