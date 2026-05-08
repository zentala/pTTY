# Task 015: F12 Help — Which-Key Style Popup

**Status:** 📋 BACKLOG (v0.2)
**Priority:** HIGH
**Created:** 2026-05-08
**Depends on:** Task 013 (path fix)

---

## Problem

Current F12 opens a *parallel tmux session* `help` running `cat <<EOF ... sleep infinity`:

- Static text wall, identical regardless of context
- Outdated (says "F1-F7" while bindings exist for F1-F10)
- Pseudo-session pollutes session list
- `sleep infinity` is a code smell — session exists only to hold a screen
- No search, no grouping, no live reflection of actual bindings

## Goal

Replace with **which-key style** discoverable, live, contextual help — popup overlay, generated from actual `tmux list-keys` output, grouped, searchable.

## Design

### Invocation
```tmux
bind-key -n C-F12 display-popup -E -w 80% -h 80% \
  "#{PTTY_DIR}/src/help-popup.sh"
```

### Layout
```
┌─ pTTY Help ─────────────────────────  [/] search  [g] group  [q] close ─┐
│                                                                          │
│  NAVIGATION                                                              │
│    F1 .. F10            jump to console 1..10                            │
│    Ctrl+←  Ctrl+→       prev / next console                              │
│    Ctrl+L               last console                                     │
│                                                                          │
│  MANAGEMENT                                                              │
│    F11                  open Manager (popup)                             │
│    Ctrl+R               restart current console (confirm)                │
│    Ctrl+D               safe detach                                      │
│    Ctrl+N               new console in next free slot                    │
│                                                                          │
│  DISPLAY                                                                 │
│    F12                  this help                                        │
│    Ctrl+H               shortcuts cheat-sheet                            │
│                                                                          │
│  TMUX PREFIX (Ctrl+B)                                                    │
│    1..0                 jump to console 1..10                            │
│    S                    session tree picker                              │
│    L                    last session                                     │
│                                                                          │
│  About: pTTY v0.2  ·  github.com/zentala/ptty  ·  by zentala             │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

### Behavior

- **Auto-generated**: parse `tmux list-keys -T root` and `tmux list-keys -T prefix`, group by description tags (e.g. `# group: navigation` comments in tmux.conf)
- **Live**: reflects the *actual* current bindings, not stale docs
- **Searchable**: `/` filters the visible bindings (fzf-style fuzzy)
- **Groupable**: `g` toggles grouping (by category / alphabetical / by-key)
- **Closable**: `q` / `Esc` / `F12` (toggle)

### Implementation

1. Annotate bindings in `tmux.conf` with structured comments:
   ```tmux
   # @group: navigation @desc: Jump to console 1
   bind-key -n C-F1 switch-client -t console-1
   ```
2. `help-popup.sh` parses the conf (or uses `tmux list-keys -N` for natural-language descriptions if available).
3. Renders via `gum` or fzf-as-pager.

### Why which-key, not menu

Which-key is *discoverable* — you press the prefix and see what's possible without committing. tmux-menus is execution-oriented. Help should answer "what can I do?", not "do this thing".

## Acceptance

- F12 opens popup, no `help` session in `list-sessions`
- All currently-bound keys appear, grouped
- Adding a new binding to `tmux.conf` (with the comment annotation) makes it appear in F12 without code changes
- `/` search works
- Closes cleanly on `q`/`Esc`/`F12`

## Plugin alternative

Consider adopting **`alberti42/tmux-which-key`** instead of rolling our own. Evaluate:
- Pros: maintained, well-tested, supports nested menus
- Cons: extra dependency, opinionated about config format

Decision: prototype both, pick one before v0.2 freeze.

## Out of scope

- Inline interactive tutorials (v1.0)
- Per-context help (different help when in Manager vs console) — v0.3
