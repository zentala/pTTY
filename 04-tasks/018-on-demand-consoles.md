**Purpose:** Make consoles 6–10 actually on-demand. Today `src/setup.sh` eagerly creates all sessions on startup; the spec promises lazy creation on first `Ctrl+F6`–`F10` press. Closing that gap unlocks the "5 active + 5 suspended" model that README and VALUE-PROPOSITION already describe.

---

# Task 018: On-demand consoles for F6–F10

**Status:** Pending
**Priority:** Medium (spec/implementation gap; doesn't block v0.2 release but blocks honest marketing of the 5-active+5-suspended model)
**Type:** Feature / Bugfix
**Estimated effort:** 2–4 hours
**Depends on:** None
**Blocks:** Status-bar polish task that wants to render F6–F10 as "dormant" vs F1–F5 "active"

---

## Context

`CLAUDE.md`, `README.md`, and `01-vision/VALUE-PROPOSITION.md` all describe the model as:

- **5 active consoles (F1–F5)** — created on startup, always running
- **5 suspended consoles (F6–F10)** — created on demand (first F-key press), idle otherwise
- **F11** — Manager Menu
- **F12** — Keyboard cheatsheet

Current implementation in `src/setup.sh:4`:

```bash
sessions=("console-1" "console-2" "console-3" "console-4" "console-5" "console-6" "console-7")
for session in "${sessions[@]}"; do
    tmux has-session -t "$session" 2>/dev/null || tmux new-session -d -s "$session" -n "main"
done
```

…eagerly creates 7 (not 5, and not 10) sessions on startup. There is no lazy-creation path for F6–F10.

This is the spec/implementation gap.

## Goal

`Ctrl+F6`–`Ctrl+F10` should:

1. Switch to `console-N` if it already exists
2. Otherwise create `console-N` (detached, then attach) and switch to it
3. Surface the existence/absence in the status bar so F6–F10 visually differ from F1–F5 until used

## Acceptance Criteria

- [ ] `src/setup.sh` creates only `console-1`…`console-5` on startup (not 1–7)
- [ ] `Ctrl+F6`–`Ctrl+F10` keybinds in `src/tmux.conf` use `if-shell "tmux has-session -t console-N" "switch-client -t console-N" "new-session -d -s console-N \\; switch-client -t console-N"` (or equivalent)
- [ ] Status bar visually distinguishes existing-but-current vs existing-but-inactive vs not-yet-created consoles for slots 6–10 (icons defined in `docs/ICONS-NETWORK-SET.md` already cover this: Active / Available / Suspended)
- [ ] `tests/test-status-bar.sh` (or a new test) verifies the three visual states render correctly
- [ ] Pressing the same `Ctrl+F6` twice does **not** re-create the session (idempotent — second press is a no-op switch)
- [ ] After `tmux kill-session -t console-6`, `Ctrl+F6` re-creates it cleanly
- [ ] `src/connect.sh` no longer assumes consoles 6–10 exist; numeric prompt path also lazily creates

## Implementation Notes

### `src/setup.sh` — eager → lazy

```bash
# Replace the loop body with:
active_sessions=("console-1" "console-2" "console-3" "console-4" "console-5")
for session in "${active_sessions[@]}"; do
    tmux has-session -t "$session" 2>/dev/null || tmux new-session -d -s "$session" -n "main"
done
# Sessions 6–10 are NOT pre-created. They appear on first Ctrl+F<N> press.
```

### `src/tmux.conf` — lazy F-key binds for 6–10

For each N in 6..10, replace the current direct `switch-client` with:

```tmux
bind-key -n C-F6 if-shell "tmux has-session -t console-6" \
  "switch-client -t console-6" \
  "new-session -d -s console-6 -n main ; switch-client -t console-6"
```

(Repeat for F7–F10. F1–F5 stay as plain `switch-client -t console-N` because those are guaranteed to exist after setup.sh.)

### Status bar

The icon source-of-truth at `docs/ICONS-NETWORK-SET.md:130-141` already defines the three states. The status-bar format string in `src/status-format-v4.tmux` needs a conditional per slot 6–10:

```tmux
#{?#{S:console-6},#{?#{==:#{session_name},console-6},<Active icon>,<Available icon>},<Suspended icon>}
```

(Pseudocode — adapt to actual format-string syntax in v4.)

## Testing Requirements

- Manual: clean `tmux kill-server`, run setup, verify `tmux ls` shows only 5 sessions
- Manual: press `Ctrl+F6` — console-6 appears in `tmux ls` and you land in it
- Manual: press `Ctrl+F1` then `Ctrl+F6` repeatedly — verify no duplicates or orphans
- Automated: extend `tests/test-status-bar.sh` with assertions on the three icon states
- Visual: take before/after screenshots for status bar (docs in `tests/STATUS-BAR-TESTS.md`)

## Out of Scope

- Auto-hibernate / suspend already-running consoles (e.g., after N hours idle) — that's a different feature
- Configurable count (let user pick 5 active + N on-demand) — keep 5+5 for v0.2; revisit in v0.3 if requested
- Persisting "which on-demand consoles were used last session" — no, on-demand means fresh each install

## Done Definition

1. Fresh install → `tmux ls` shows 5 sessions, not 7 or 10
2. `Ctrl+F6` creates console-6 on first press, switches to it on second press
3. Status bar correctly shows Active/Available/Suspended icons per slot
4. All existing tests pass; new test for lazy-creation passes
5. README/VALUE-PROPOSITION claims match reality — no further copy edits needed
