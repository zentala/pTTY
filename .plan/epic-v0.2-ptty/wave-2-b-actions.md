# Wave 2-B — `src/actions/*.sh` (mutating actions)

**Wave:** 2 (core refactor, parallel with 2-A and 2-C)
**Depends on:** Wave 1
**Worktree branch:** `feature/wave-2b-actions`
**Architecture sections:** [§B file layout](ARCHITECTURE.md), [§I error handling](ARCHITECTURE.md)
**Maps to legacy task:** [04-tasks/003-refactor-actions.md](../../04-tasks/003-refactor-actions.md)

---

## Why

Today the action logic is tangled inside `mission-control.sh` (`restart_session()`) and `restart-confirm.sh`. There's no `kill`, no `new`, no `rename`. F11 popup (Wave 3) needs to call individual atomic action scripts so it can stay UI-only.

Each action: one script, one job, callable from CLI, atomic, lock-protected, with consistent exit codes.

## Starting state

- `src/ui/manager.sh` (after Wave 1 rename) has `restart_session()` inline.
- `src/actions/restart.sh` exists (after Wave 1 rename of `restart-confirm.sh`) but is the popup version, not the action version.
- No `kill.sh`, `rename.sh`, `new.sh`, `attach.sh`, `detach.sh`.
- Lock-file logic in `mission-control.sh` reusable, but currently inline.

## Deliverable

Six scripts in `src/actions/`. All start with `set -euo pipefail`, all source `src/lib/log.sh` for consistent output, all use the same lock pattern from `src/lib/locks.sh` (created in Wave 2-C).

### 1. `src/actions/attach.sh`

```bash
#!/usr/bin/env bash
# attach.sh <slot_n>
# Switches the calling client to console-N. Creates session if missing.
set -euo pipefail
n="${1:?slot number required}"
source "${PTTY_DIR}/src/core/slots.sh"
slots_validate "$n" || { echo "invalid slot: $n" >&2; exit 2; }
session="console-$n"
if ! tmux has-session -t "$session" 2>/dev/null; then
  tmux new-session -d -s "$session" -n main
fi
tmux switch-client -t "$session"
```

### 2. `src/actions/kill.sh`

```bash
#!/usr/bin/env bash
# kill.sh <slot_n>
# Kills the session at console-N. No-op if already dead.
set -euo pipefail
n="${1:?slot number required}"
source "${PTTY_DIR}/src/core/slots.sh"
source "${PTTY_DIR}/src/core/state.sh"
source "${PTTY_DIR}/src/lib/locks.sh"
slots_validate "$n" || { echo "invalid slot: $n" >&2; exit 2; }
session="console-$n"
locks_acquire "$session" || { echo "busy: $session" >&2; exit 3; }
trap 'locks_release "$session"' EXIT
tmux has-session -t "$session" 2>/dev/null && tmux kill-session -t "$session"
state_invalidate
```

### 3. `src/actions/restart.sh`

Replaces the popup `restart-confirm.sh` (which becomes Wave 3's `confirm.sh` callable from manager).

```bash
#!/usr/bin/env bash
# restart.sh <slot_n>
# Kills + recreates console-N. Atomic via lock-file.
set -euo pipefail
n="${1:?slot number required}"
source "${PTTY_DIR}/src/core/slots.sh"
source "${PTTY_DIR}/src/core/state.sh"
source "${PTTY_DIR}/src/lib/locks.sh"
slots_validate "$n" || exit 2
session="console-$n"
locks_acquire "$session" || exit 3
trap 'locks_release "$session"' EXIT

if tmux has-session -t "$session" 2>/dev/null; then
  tmux kill-session -t "$session"
  for i in $(seq 1 50); do
    tmux has-session -t "$session" 2>/dev/null || break
    sleep 0.1
  done
fi
tmux new-session -d -s "$session" -n main
state_invalidate
```

### 4. `src/actions/rename.sh`

```bash
#!/usr/bin/env bash
# rename.sh <slot_n> <new_window_name>
# Renames the *window* (not session). Slot identity is structural; see ADR-009.
set -euo pipefail
n="${1:?slot number required}"
new_name="${2:?new name required}"
source "${PTTY_DIR}/src/core/slots.sh"
source "${PTTY_DIR}/src/core/state.sh"
slots_validate "$n" || exit 2
session="console-$n"
tmux has-session -t "$session" 2>/dev/null || { echo "no session: $session" >&2; exit 4; }
tmux rename-window -t "$session" "$new_name"
state_invalidate
```

### 5. `src/actions/new.sh`

```bash
#!/usr/bin/env bash
# new.sh [slot_n]
# Creates console at given slot, or lowest free if no arg.
set -euo pipefail
source "${PTTY_DIR}/src/core/slots.sh"
source "${PTTY_DIR}/src/core/state.sh"
n="${1:-$(slots_lowest_free)}"
[ -z "$n" ] && { echo "all 10 slots in use" >&2; exit 5; }
slots_validate "$n" || exit 2
session="console-$n"
tmux has-session -t "$session" 2>/dev/null && { echo "already exists: $session" >&2; exit 6; }
tmux new-session -d -s "$session" -n main
state_invalidate
echo "$n"   # caller can read which slot was used
```

### 6. `src/actions/detach.sh`

```bash
#!/usr/bin/env bash
# detach.sh
# Safe detach: leaves all sessions running. Replaces "Ctrl+D" handler if any.
set -euo pipefail
tmux detach-client
```

### Exit code contract

| Code | Meaning |
|------|---------|
| 0 | success |
| 2 | invalid argument (slot out of range, missing arg) |
| 3 | busy (lock held by another action) |
| 4 | session not found (when one was expected) |
| 5 | no free slot (new.sh) |
| 6 | session already exists (new.sh with explicit slot) |
| ≥10 | reserved for tmux failures (let propagate) |

### Tests — `tests/unit/actions.bats`

```bats
@test "kill.sh on slot N removes the session" { ... }
@test "kill.sh on empty slot is no-op (exit 0)" { ... }
@test "kill.sh on slot 11 exits 2" { ... }
@test "restart.sh recreates the session, slot identity preserved" { ... }
@test "new.sh with no arg picks lowest free slot" { ... }
@test "new.sh on used slot exits 6" { ... }
@test "rename.sh changes window name only, session name unchanged" { ... }
@test "concurrent kill.sh on same slot: second exits 3" { ... }
```

## Acceptance

- [ ] All six scripts exist in `src/actions/` and are `shellcheck`-clean
- [ ] Each script has `--help` flag printing usage (one-liner OK)
- [ ] Exit codes follow the contract above
- [ ] `kill.sh` is a no-op (exit 0) on empty slot — does NOT exit 4
- [ ] `restart.sh` preserves slot identity (`console-3` after restart is still `console-3`)
- [ ] `new.sh` without args picks lowest free; with arg, refuses if used (exit 6)
- [ ] `rename.sh` changes window name only; `tmux list-sessions` still shows `console-3`
- [ ] Concurrent kill on same slot: second invocation exits 3 (lock busy)
- [ ] All scripts call `state_invalidate` after mutation
- [ ] `tests/unit/actions.bats` covers all listed cases and passes

## Out of scope

- F11 popup binding to these actions (Wave 3)
- Confirm dialogs (Wave 3 — UI concern, not action concern)
- `lib/locks.sh` and `lib/log.sh` themselves (Wave 2-C)

## Risks

- **Race between `tmux kill-session` and `tmux has-session` poll** — if the session takes longer than 5s to die. Mitigation: 50 × 0.1s loop = 5s timeout, then error exit 10+.
- **tmux server dies mid-restart** — leave lock file orphaned. Mitigation: `lib/locks.sh` writes PID; lock acquire checks if PID still alive, treats stale lock as free.
- **Path with spaces in `$PTTY_DIR`** — all `source` calls use double-quoted `"${PTTY_DIR}/..."`.
