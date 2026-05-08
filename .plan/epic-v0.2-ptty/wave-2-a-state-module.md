# Wave 2-A — `src/core/state.sh` module

**Wave:** 2 (core refactor, parallel)
**Depends on:** Wave 1
**Worktree branch:** `feature/wave-2a-state`
**Architecture sections:** [§B file layout](ARCHITECTURE.md), [§D data model](ARCHITECTURE.md), [§C process model — caching](ARCHITECTURE.md)
**Maps to legacy task:** [04-tasks/001-refactor-state-management.md](../../04-tasks/001-refactor-state-management.md)

---

## Why

Today, `mission-control.sh` is a 245-line monolith that builds the session list, formats rows, and runs fzf in one go. The list-building logic isn't testable, can't be reused by other UI surfaces (status bar, help), and parses `awk` on its own display rows.

This wave extracts the **read side** of console state: a function library that, given nothing, returns a typed list of consoles with status, uptime, last command, and resource usage. Pure reads — no `tmux new-session`, no `kill-session`.

## Starting state

- `src/ui/manager.sh` (after Wave 1 rename) contains `build_session_list()` mixing tmux reads, formatting, and parsing.
- No caching — every F11 press hits tmux 10× for 10 consoles + 10× for `ps`.
- No structured representation; everything is display strings.

## Deliverable

### 1. `src/core/state.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

# state_list — returns tab-separated rows for all 10 F-slots:
#   $F_KEY\t$KIND\t$SESSION\t$UPTIME_SEC\t$LAST_CMD\t$CPU_PCT\t$MEM_KB\t$EXTRA_JSON
# KIND ∈ {live, idle, sleep, dead, slot}
# Empty fields are "-" not empty string (fzf-safe).
state_list() {
  local cache_ts cache_data now
  now=$(date +%s)
  cache_ts=$(tmux show-option -gqv @ptty_state_cache_ts 2>/dev/null || echo 0)

  if (( now - cache_ts < 5 )); then
    tmux show-option -gqv @ptty_state_cache_data 2>/dev/null && return 0
  fi

  local rows=""
  for n in 1 2 3 4 5 6 7 8 9 10; do
    rows+="$(state_one "$n")"$'\n'
  done
  rows="${rows%$'\n'}"

  tmux set-option -gq @ptty_state_cache_ts "$now"
  tmux set-option -gq @ptty_state_cache_data "$rows"
  printf '%s\n' "$rows"
}

# state_one <slot_n>
state_one() {
  local n="$1" session="console-$1" fkey="F$1"
  if ! tmux has-session -t "$session" 2>/dev/null; then
    printf 'F%s\tslot\t-\t-\t-\t-\t-\t{}\n' "$n"
    return
  fi
  if [[ -f "${PTTY_DIR:-$HOME/.ptty}/run/suspended/$session" ]]; then
    local since
    since=$(stat -c %Y "${PTTY_DIR}/run/suspended/$session" 2>/dev/null || echo 0)
    printf 'F%s\tsleep\t%s\t%s\t%s\t-\t-\t{}\n' \
      "$n" "$session" "$((`date +%s` - since))" "auto-suspended"
    return
  fi
  # tmux returns pane info even for crashed; we treat any list-windows error as 'dead'
  local pid cmd uptime created
  if ! created=$(tmux display-message -p -t "$session" '#{session_created}' 2>/dev/null); then
    printf 'F%s\tdead\t%s\t-\t-\t-\t-\t{}\n' "$n" "$session"
    return
  fi
  uptime=$(( $(date +%s) - created ))
  pid=$(tmux display-message -p -t "$session" '#{pane_pid}' 2>/dev/null || echo 0)
  cmd=$(tmux display-message -p -t "$session" '#{pane_current_command}' 2>/dev/null || echo "-")

  local kind="live"
  case "$cmd" in
    bash|zsh|sh|fish|dash) kind="idle" ;;
  esac

  local cpu="-" mem="-"
  if [[ "$pid" != 0 ]]; then
    read -r cpu mem < <(ps -o %cpu=,rss= -p "$pid" 2>/dev/null | awk '{print $1, $2}')
    cpu="${cpu:--}"; mem="${mem:--}"
  fi
  printf 'F%s\t%s\t%s\t%s\t%s\t%s\t%s\t{}\n' \
    "$n" "$kind" "$session" "$uptime" "$cmd" "$cpu" "$mem"
}

# state_invalidate — drop cache, force fresh read on next state_list
state_invalidate() {
  tmux set-option -gqu @ptty_state_cache_ts
  tmux set-option -gqu @ptty_state_cache_data
}
```

### 2. `src/core/slots.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

# slots_lowest_free — prints lowest free F-slot number, or empty if all 10 used.
slots_lowest_free() {
  source "${PTTY_DIR:-$HOME/.ptty}/src/core/state.sh"
  state_list | awk -F'\t' '$2 == "slot" {print $1; exit}' | tr -d 'F'
}

# slots_validate <n> — exit 0 if n is 1..10, else exit 1
slots_validate() {
  [[ "$1" =~ ^([1-9]|10)$ ]]
}
```

### 3. Tests — `tests/unit/state.bats`

```bats
#!/usr/bin/env bats

setup() {
  export PTTY_DIR="$BATS_TEST_TMPDIR/ptty"
  mkdir -p "$PTTY_DIR/src/core"
  cp "$BATS_TEST_DIRNAME/../../src/core/state.sh" "$PTTY_DIR/src/core/"
  cp "$BATS_TEST_DIRNAME/../../src/core/slots.sh" "$PTTY_DIR/src/core/"
  tmux -L ptty-test kill-server 2>/dev/null || true
  export TMUX_TMPDIR="$BATS_TEST_TMPDIR/tmux"
  mkdir -p "$TMUX_TMPDIR"
}

teardown() {
  tmux -L ptty-test kill-server 2>/dev/null || true
}

@test "state_list returns 10 rows for empty server" {
  source "$PTTY_DIR/src/core/state.sh"
  run state_list
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | wc -l)" -eq 10 ]
}

@test "all rows are 'slot' when no sessions" {
  source "$PTTY_DIR/src/core/state.sh"
  run state_list
  [ "$(echo "$output" | awk -F'\t' '$2 != "slot"' | wc -l)" -eq 0 ]
}

@test "console-3 shows as idle when bash session exists" {
  tmux -L ptty-test new-session -d -s console-3 'bash'
  source "$PTTY_DIR/src/core/state.sh"
  TMUX_TMPDIR="$TMUX_TMPDIR" run state_list
  [[ "$output" =~ "F3"$'\t'"idle"$'\t'"console-3" ]]
}

@test "slots_lowest_free returns 1 when all empty" {
  source "$PTTY_DIR/src/core/slots.sh"
  run slots_lowest_free
  [ "$output" = "1" ]
}

@test "slots_validate accepts 1..10, rejects 0 and 11" {
  source "$PTTY_DIR/src/core/slots.sh"
  slots_validate 1
  slots_validate 10
  ! slots_validate 0
  ! slots_validate 11
  ! slots_validate abc
}
```

## Acceptance

- [ ] `src/core/state.sh` and `src/core/slots.sh` exist and are `shellcheck`-clean
- [ ] `state_list` returns exactly 10 tab-separated rows on a fresh tmux server
- [ ] Status detection matches rules in [ARCHITECTURE.md §D.2](ARCHITECTURE.md):
  - No session → `slot`
  - Foreground proc is shell → `idle`
  - Foreground proc is non-shell → `live`
  - Suspended marker file present → `sleep`
  - tmux errors on read → `dead`
- [ ] Cache TTL is 5 seconds; second call within 5s reads from cache (verified by stubbing tmux to error on second call → first returned, second still returns)
- [ ] `state_invalidate` drops cache; next `state_list` re-reads
- [ ] `slots_lowest_free` returns lowest unused number, empty when all 10 in use
- [ ] All bats tests in `tests/unit/state.bats` pass
- [ ] `tmux show-options -gv @ptty_state_cache_ts` after a list call returns a recent timestamp

## Out of scope

- Wave 2-B: action scripts that mutate state
- Wave 2-C: shared `lib/` formatters
- Wave 3: actual F11 popup that displays this data
- Auto-suspend marker mechanism (assumes someone else writes the marker file; pTTY just reads it)

## Risks

- `tmux show-option @ptty_state_cache_data` truncates on multiline values — verify with 10-row payload (~1KB) doesn't hit any tmux internal limit. Fallback: cache to `$XDG_CACHE_HOME/ptty/state.cache`.
- `ps -o %cpu=,rss=` portability — busybox `ps` uses different flags. Mitigation: feature-detect in `lib/ps.sh` (Wave 2-C); state.sh just calls it.
