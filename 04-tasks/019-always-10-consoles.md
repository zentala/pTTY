**Purpose:** Drop the "5 active + 5 on-demand" mental model. Make pTTY always create 10 consoles on startup. Simpler setup, simpler tmux.conf, simpler status bar, simpler README — at the cost of ~30–50 MB of idle bash RSS on the server, which is noise on any modern VPS.

---

# Task 019: Normalize to 10 always-on consoles (supersedes task 018)

**Status:** Pending
**Priority:** High (unblocks honest README copy and the v0.2 status-bar work)
**Type:** Refactor / Simplification
**Estimated effort:** 1–2 hours
**Depends on:** None
**Supersedes:** `018-on-demand-consoles.md` (close that task with a pointer to this one)
**Blocks:** Task 020 (README DevEx) — copy decisions depend on this

---

## Context

Today's state:
- `src/setup.sh` creates **7** sessions (`console-1`…`console-7`) on startup — already inconsistent with both v0.1 docs ("7 persistent") and v0.2 spec ("5 + 5 on-demand")
- README and VALUE-PROPOSITION currently claim "5 active + 5 on-demand = 10 keyboard slots"
- That model creates three classes of complexity:
  1. **Implementation**: `if-shell` lazy-creation in `tmux.conf` for F6–F10; setup.sh special-cases first 5
  2. **Status bar**: must render 3 visual states per slot (Active / Available / Suspended) and recompute on every F-key press
  3. **Marketing copy**: every mention of consoles has to clarify "5 ready, 5 on-demand" — adds friction every paragraph

The simpler alternative: **always create 10 sessions on startup**. Idle bash processes consume ~3–5 MB RSS each (~30–50 MB total). On any VPS ≥ 1 GB this is in the noise floor.

## Goal

`setup.sh` creates `console-1`…`console-10` unconditionally. `Ctrl+F1`–`F10` are 10 simple `switch-client -t console-N` binds. Status bar has 2 states per slot: **current** (highlighted) and **other** (dim). README and VALUE-PROPOSITION drop all "on-demand" / "suspended" language.

## Acceptance Criteria

- [ ] `src/setup.sh` creates `console-1`…`console-10` (not 7, not 5+lazy)
- [ ] `src/tmux.conf` binds `Ctrl+F1`–`Ctrl+F10` as plain `switch-client -t console-N` (no `if-shell`, no lazy creation)
- [ ] `src/tmux.conf` retains `Ctrl+F11` = Manager Menu, `Ctrl+F12` = Cheatsheet (unchanged)
- [ ] Status bar (`src/status-format-v4.tmux`) renders 10 slots with 2 visual states: current vs other
- [ ] README has zero occurrences of "on-demand", "suspended", "available on demand" describing consoles 6–10
- [ ] VALUE-PROPOSITION has zero occurrences of those phrases too
- [ ] Key Bindings Reference table merges "Active Consoles" + "Suspended Consoles" into one "Consoles (F1–F10)" section
- [ ] `tmux ls` after fresh install shows exactly 10 sessions
- [ ] `src/connect.sh` numeric menu accepts 1–10 (today it accepts 1–7)
- [ ] Task 018 marked `## Status: superseded by 019` at top, body kept for history

## Implementation Notes

### `src/setup.sh` — flat loop

```bash
for i in {1..10}; do
    session="console-$i"
    tmux has-session -t "$session" 2>/dev/null || tmux new-session -d -s "$session" -n "main"
done
```

### `src/tmux.conf` — 10 plain binds

```tmux
bind-key -n C-F1 switch-client -t console-1
bind-key -n C-F2 switch-client -t console-2
# ...repeat through C-F10
bind-key -n C-F10 switch-client -t console-10

bind-key -n C-F11 run-shell "~/.vps/sessions/src/manager.sh"   # unchanged
bind-key -n C-F12 run-shell "~/.vps/sessions/src/help.sh"      # unchanged
```

### Status bar — 2 states, not 3

For each slot N in 1..10:

```tmux
#{?#{==:#{session_name},console-N},<current icon + highlight>,<other icon + dim>}
```

Pick icons from `docs/ICONS-NETWORK-SET.md`:
- Current → "Active" icon (󰢩 f08a9)
- Other → "Available" icon (󰱠 f0c60)

Drop the "Suspended" icon (󰲝 f0c9d) from the runtime palette. Keep it documented in ICONS source-of-truth for completeness, but mark "unused since v0.2 — see task 019".

### Docs sweep

`README.md`:
- Hero `Ctrl+F1`–`F10` line stays
- "5 active + 5 on-demand" → "10 always-on consoles"
- Key Bindings Reference: merge two tables into one
- Project Structure tree comment: "Creates 5 persistent sessions" → "Creates 10 persistent sessions"

`01-vision/VALUE-PROPOSITION.md`:
- TL;DR: drop "5 + 5" framing
- Unique combination bullet #1: "Zero configuration — 10 always-on `console-1`…`console-10` sessions created by one install command"
- ALWAYS-write block warning #2 about F-key map can drop the "5 active vs 5 on-demand" sub-clause

`CLAUDE.md`:
- Rule #9: collapse the F1–F5 / F6–F10 split into "Ctrl+F1–F10 = consoles 1–10 (all always-on after install)"
- Drop reference to "suspended" / "on-demand" entirely

## Testing Requirements

- Fresh install on clean Linux box (Docker test rig in `tests/docker/`): verify `tmux ls` shows 10 sessions
- Press each `Ctrl+F1` through `Ctrl+F10`: each switches instantly, no creation lag
- Reboot the test container, re-run setup: idempotent (10 sessions, not 20)
- Status bar visual snapshot: 10 slots visible at 80-col width (verify it fits; if not, that's a separate status-bar task)
- Manager menu (`Ctrl+F11`) still works
- Cheatsheet (`Ctrl+F12`) still works

## Out of Scope

- Configurable count (let user choose 5 vs 10 vs 20) — keep it fixed at 10 for v0.2. If demand emerges, revisit in v0.3.
- Renaming sessions to anything other than `console-N` — separate concern
- Adding per-session purpose labels ("claude", "git", "logs") — README's "Suggested use" column already documents this as convention; if we ever implement real labels it's a new task

## Done Definition

1. Fresh install → `tmux ls` shows exactly 10 sessions
2. Every `Ctrl+F1`–`F10` switches without creation delay
3. README, VALUE-PROPOSITION, CLAUDE.md contain zero "on-demand" / "suspended" language about consoles
4. Status bar fits on 80 cols (or this surfaces a separate status-bar fit task)
5. Task 018 file annotated as superseded
