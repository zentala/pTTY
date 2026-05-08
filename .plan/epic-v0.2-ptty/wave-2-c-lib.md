# Wave 2-C — `src/lib/*.sh` (shared helpers)

**Wave:** 2 (core refactor, parallel with 2-A and 2-B)
**Depends on:** Wave 1
**Worktree branch:** `feature/wave-2c-lib`
**Architecture sections:** [§B file layout](ARCHITECTURE.md), [§I error handling](ARCHITECTURE.md)

---

## Why

Eliminate two anti-patterns in current code:

1. **`awk '{print $3}'` on display rows** (mission-control.sh:71, :196). Fragile — change a column width, parsing breaks.
2. **Inline `ps`, no consistent CPU/Mem helper** — busybox/POSIX/GNU `ps` flag differences will hit Linux/macOS users.

Provide three small libraries used by Wave 2-A (state) and 2-B (actions).

## Starting state

- No `src/lib/` directory.
- `ps` invocations scattered.
- Logging is `echo` to stdout/stderr inconsistently.
- Lock-file logic inline in mission-control.sh:111-139.

## Deliverable

### 1. `src/lib/tmux.sh` — typed-ish wrappers

```bash
#!/usr/bin/env bash
set -euo pipefail

# tmux_session_exists <name>  → exit 0 if exists, 1 otherwise
tmux_session_exists() { tmux has-session -t "$1" 2>/dev/null; }

# tmux_session_created <name>  → unix timestamp, or empty if no session
tmux_session_created() {
  tmux display-message -p -t "$1" '#{session_created}' 2>/dev/null
}

# tmux_pane_pid <session>  → pid of current pane, or 0
tmux_pane_pid() {
  tmux display-message -p -t "$1" '#{pane_pid}' 2>/dev/null || echo 0
}

# tmux_pane_cmd <session>  → current foreground command name
tmux_pane_cmd() {
  tmux display-message -p -t "$1" '#{pane_current_command}' 2>/dev/null || echo "-"
}

# tmux_capture_tail <session> [n_lines]  → last N lines of current pane
tmux_capture_tail() {
  local lines="${2:-15}"
  tmux capture-pane -t "$1" -p -S "-$lines" 2>/dev/null
}
```

### 2. `src/lib/format.sh` — row formatting (no display-row awk)

```bash
#!/usr/bin/env bash
set -euo pipefail

# format_row <fkey> <kind> <session> <uptime_sec> <last_cmd> <cpu> <mem>
# Emits a tab-separated row. Empty fields are "-".
format_row() {
  local f="${1:--}" k="${2:--}" s="${3:--}" u="${4:--}" c="${5:--}" cp="${6:--}" m="${7:--}"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$f" "$k" "$s" "$u" "$c" "$cp" "$m"
}

# format_uptime <seconds>  → human "2h 14m" / "45m" / "3m" / "12s"
format_uptime() {
  local s="${1:-0}" h m
  [ "$s" = "-" ] && { echo "-"; return; }
  if (( s >= 3600 )); then
    h=$((s / 3600)); m=$(( (s % 3600) / 60 ))
    printf '%dh %02dm\n' "$h" "$m"
  elif (( s >= 60 )); then
    printf '%dm\n' $((s / 60))
  else
    printf '%ds\n' "$s"
  fi
}

# format_mem_kb <kb>  → "84M" / "1.2G" / "12K"
format_mem_kb() {
  local kb="${1:-0}"
  [ "$kb" = "-" ] && { echo "-"; return; }
  if (( kb >= 1048576 )); then
    awk -v k="$kb" 'BEGIN{printf "%.1fG\n", k/1048576}'
  elif (( kb >= 1024 )); then
    printf '%dM\n' $((kb / 1024))
  else
    printf '%dK\n' "$kb"
  fi
}

# parse_field <row> <col_index>  → extract column N from tab-row (1-indexed)
parse_field() {
  printf '%s\n' "$1" | awk -F'\t' -v c="$2" '{print $c}'
}
```

### 3. `src/lib/ps.sh` — portable CPU/Mem

```bash
#!/usr/bin/env bash
set -euo pipefail

# ps_cpu_mem <pid>  → "<cpu_pct> <mem_kb>"; "-  -" if pid invalid
ps_cpu_mem() {
  local pid="${1:-0}"
  [[ "$pid" =~ ^[0-9]+$ ]] && [ "$pid" -gt 0 ] || { echo "- -"; return; }

  # GNU/BSD/macOS all support these short flags
  local out
  if out=$(ps -o %cpu=,rss= -p "$pid" 2>/dev/null); then
    # %cpu rss → CPU% MEM_KB
    echo "$out" | awk '{print $1, $2}'
  else
    echo "- -"
  fi
}
```

### 4. `src/lib/locks.sh` — atomic action gating

```bash
#!/usr/bin/env bash
set -euo pipefail

LOCK_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/ptty/locks"

# locks_acquire <name>  → exit 0 if acquired, 1 if busy
locks_acquire() {
  local name="$1" lock="$LOCK_DIR/$1.lock"
  mkdir -p "$LOCK_DIR" && chmod 700 "$LOCK_DIR"

  if [[ -f "$lock" ]]; then
    local owner_pid
    owner_pid=$(cat "$lock" 2>/dev/null)
    if [[ -n "$owner_pid" ]] && kill -0 "$owner_pid" 2>/dev/null; then
      return 1   # busy, owner alive
    fi
    # stale lock — owner dead, take it over
  fi
  echo $$ > "$lock"
}

# locks_release <name>
locks_release() {
  local lock="$LOCK_DIR/$1.lock"
  [[ -f "$lock" ]] && [[ "$(cat "$lock" 2>/dev/null)" = "$$" ]] && rm -f "$lock"
  return 0
}
```

### 5. `src/lib/log.sh` — consistent error/info

```bash
#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/ptty/log"

log_init() { mkdir -p "$(dirname "$LOG_FILE")"; }

log_info() { log_init; printf '[%s] INFO  %s\n' "$(date -Iseconds)" "$*" >> "$LOG_FILE"; }
log_warn() { log_init; printf '[%s] WARN  %s\n' "$(date -Iseconds)" "$*" >> "$LOG_FILE"; echo "$*" >&2; }
log_err()  { log_init; printf '[%s] ERROR %s\n' "$(date -Iseconds)" "$*" >> "$LOG_FILE"; echo "$*" >&2; }

# log_tail [n]  → print last N lines of log
log_tail() { tail -n "${1:-20}" "$LOG_FILE" 2>/dev/null; }
```

### Tests — `tests/unit/lib.bats`

```bats
@test "format_uptime: 0 → '0s'" { ... }
@test "format_uptime: 45 → '45s'" { ... }
@test "format_uptime: 60 → '1m'" { ... }
@test "format_uptime: 3661 → '1h 01m'" { ... }
@test "format_mem_kb: 12 → '12K'" { ... }
@test "format_mem_kb: 84000 → '82M'" { ... }
@test "format_mem_kb: 2097152 → '2.0G'" { ... }
@test "ps_cpu_mem on PID 1 returns numeric values" { ... }
@test "ps_cpu_mem on PID 99999 returns '- -'" { ... }
@test "locks_acquire / locks_release roundtrip" { ... }
@test "locks_acquire fails when locked by live process" { ... }
@test "locks_acquire takes over stale lock (dead owner)" { ... }
@test "parse_field extracts column 3 from tab row" { ... }
```

## Acceptance

- [ ] All five files in `src/lib/` exist and are `shellcheck`-clean
- [ ] `format_uptime` matches table above for 0, 45, 60, 3661 seconds
- [ ] `format_mem_kb` matches K/M/G boundaries
- [ ] `ps_cpu_mem` returns `- -` for nonexistent PIDs (not garbage)
- [ ] `ps_cpu_mem` works on macOS BSD `ps` and Linux GNU `ps` (CI tests both)
- [ ] `locks_acquire` is atomic: 100 parallel calls → exactly 1 succeeds
- [ ] `locks_release` is no-op if not owner (multi-process safety)
- [ ] Stale lock (PID dead) is taken over correctly
- [ ] All bats tests pass on Linux + macOS CI runners

## Out of scope

- Wave 2-A `state.sh` and Wave 2-B actions (they consume these libs)
- Display-layer ANSI / color helpers — Wave 3 owns those
- i18n / locale — v0.3+

## Risks

- **`mkdir -p` race on first run** — fine for `mkdir -p`, idempotent.
- **`echo $$` lock might not be process that runs `kill`** if subshells split. Mitigation: lock acquire happens in the action script itself (top-level), not nested.
- **Rotating logs** — log file grows unbounded. v0.2 accepts this (low write volume); v0.3 adds rotation via logrotate config.
