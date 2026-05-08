# Wave 3 — F11 Manager popup (own implementation)

**Wave:** 3 (the brand-defining UX)
**Depends on:** Wave 1 (paths), Wave 2-A (state), Wave 2-B (actions), Wave 2-C (lib)
**Worktree branch:** `feature/wave-3-f11`
**Architecture sections:** [§F popup contract](ARCHITECTURE.md), [§D data model](ARCHITECTURE.md)
**Mockup:** [`02-planning/mockups/f11-f12-redesign.html`](../../02-planning/mockups/f11-f12-redesign.html)
**Maps to legacy task:** [04-tasks/014-f11-popup-redesign.md](../../04-tasks/014-f11-popup-redesign.md)

---

## Why

This is the brand. After this wave, you have a demo. F11 popup with single-key actions, live metrics, slot-aware rendering — exactly what differentiates pTTY from "tmux with a status bar".

## Starting state

After Waves 1+2:
- `src/ui/manager.sh` is the renamed/moved file but still contains the legacy two-step fzf flow.
- `src/core/state.sh` returns tab-separated rows.
- `src/actions/{kill,restart,rename,new}.sh` callable atomically.
- `src/lib/{format,tmux}.sh` available.
- F11 is bound to `display-popup -E ${PTTY_DIR}/src/ui/manager.sh`.

## Deliverable

### 1. `src/ui/manager.sh` — rewrite

Pseudocode (full implementation follows pattern):

```bash
#!/usr/bin/env bash
set -euo pipefail
source "${PTTY_DIR}/src/core/state.sh"
source "${PTTY_DIR}/src/lib/format.sh"
source "${PTTY_DIR}/src/lib/log.sh"

main() {
  local rows display preview_cmd selected
  rows=$(state_list)
  display=$(format_display "$rows")

  preview_cmd='
    s=$(echo {} | cut -f3)
    if [ "$s" != "-" ]; then
      tmux capture-pane -t "$s" -p -S -15 2>/dev/null
    else
      echo "(empty slot — press n to create)"
    fi
  '

  selected=$(printf '%s\n' "$display" | fzf \
    --ansi --no-sort --reverse \
    --header="$(banner) │ Enter switch · K kill · r restart · n new · R rename · / filter · ? help · q close" \
    --preview="$preview_cmd" --preview-window=right:55%:wrap \
    --bind 'enter:accept' \
    --bind 'shift-k:execute(${PTTY_DIR}/src/ui/confirm.sh kill {})+reload(${PTTY_DIR}/src/ui/list.sh)' \
    --bind 'r:execute(${PTTY_DIR}/src/ui/confirm.sh restart {})+reload(${PTTY_DIR}/src/ui/list.sh)' \
    --bind 'shift-r:execute(${PTTY_DIR}/src/ui/rename-prompt.sh {})+reload(${PTTY_DIR}/src/ui/list.sh)' \
    --bind 'n:execute(${PTTY_DIR}/src/actions/new.sh)+reload(${PTTY_DIR}/src/ui/list.sh)' \
    --bind '/:enable-search' \
    --bind '?:execute(${PTTY_DIR}/src/ui/help.sh)' \
    --bind 'esc:abort' --bind 'q:abort' \
    --bind '1:pos(1)' --bind '2:pos(2)' --bind '3:pos(3)' \
    --bind '4:pos(4)' --bind '5:pos(5)' --bind '6:pos(6)' \
    --bind '7:pos(7)' --bind '8:pos(8)' --bind '9:pos(9)' \
    --bind '0:pos(10)' \
  )

  if [[ -n "$selected" ]]; then
    local fkey n
    fkey=$(echo "$selected" | cut -f1)
    n="${fkey#F}"
    "${PTTY_DIR}/src/actions/attach.sh" "$n"
  fi
}

banner() { printf 'pTTY Manager'; }   # Q5 decision: pTTY branding

format_display() {
  while IFS=$'\t' read -r f kind sess uptime cmd cpu mem _; do
    local status_icon color_kind color_reset='\033[0m'
    case "$kind" in
      live)  status_icon='● live'; color_kind='\033[32m' ;;
      idle)  status_icon='○ idle'; color_kind='\033[37m' ;;
      sleep) status_icon='◐ sleep'; color_kind='\033[37m' ;;
      dead)  status_icon='✖ dead'; color_kind='\033[31m' ;;
      slot)  status_icon='· slot'; color_kind='\033[90m' ;;
    esac
    local up=$(format_uptime "$uptime")
    local mm=$(format_mem_kb "$mem")
    local sess_disp="$sess"; [ "$sess" = "-" ] && sess_disp="(empty — press n)"
    printf '%s\t%b%s%b\t%s\t%s\t%-20s\t%5s\t%6s\n' \
      "$f" "$color_kind" "$status_icon" "$color_reset" "$sess_disp" "$up" "$cmd" "$cpu" "$mm"
  done <<< "$1"
}

main "$@"
```

### 2. `src/ui/list.sh` — reload helper

Trivial wrapper that re-runs `state_list` + `format_display` for fzf `reload(...)`:

```bash
#!/usr/bin/env bash
set -euo pipefail
source "${PTTY_DIR}/src/core/state.sh"
state_invalidate
state_list | "${PTTY_DIR}/src/ui/manager-format.sh"
```

(Or inline the format function in lib.)

### 3. `src/ui/confirm.sh` — destructive action gate

```bash
#!/usr/bin/env bash
# confirm.sh <action> <fzf_row>
# Asks Yes/No; runs ${PTTY_DIR}/src/actions/<action>.sh <slot_n> on Yes.
set -euo pipefail
action="$1"; row="$2"
fkey=$(echo "$row" | cut -f1); n="${fkey#F}"
session=$(echo "$row" | cut -f3)
[ "$session" = "-" ] && exit 0   # no-op on empty slot

case "$action" in
  kill)    msg="Kill session $session?" ;;
  restart) msg="Restart session $session? (kills + recreates)" ;;
  *)       echo "unknown action: $action" >&2; exit 2 ;;
esac

# Default: No (safe)
read -r -p "$msg [y/N] " ans
case "${ans:-n}" in
  y|Y|yes) "${PTTY_DIR}/src/actions/$action.sh" "$n" ;;
  *)       exit 0 ;;
esac
```

### 4. `src/ui/rename-prompt.sh`

```bash
#!/usr/bin/env bash
# rename-prompt.sh <fzf_row>
set -euo pipefail
row="$1"
fkey=$(echo "$row" | cut -f1); n="${fkey#F}"
session=$(echo "$row" | cut -f3)
[ "$session" = "-" ] && exit 0
read -r -p "New window name for $session: " new_name
[ -z "$new_name" ] && exit 0
"${PTTY_DIR}/src/actions/rename.sh" "$n" "$new_name"
```

### 5. tmux.conf binding (verify Wave 1)

```tmux
bind-key -n C-F11 display-popup -E -w 90% -h 85% \
  -T ' pTTY Manager ' -S 'fg=cyan,bg=default' \
  '#{PTTY_DIR}/src/ui/manager.sh'
```

### Tests — `tests/smoke/popup-f11.bats`

```bats
@test "F11 opens popup with pTTY Manager header" {
  tmux -L test new-session -d
  tmux -L test send-keys C-F11
  sleep 0.5
  run tmux -L test capture-pane -p
  [[ "$output" =~ "pTTY Manager" ]]
}

@test "F11 popup shows all 10 F-slots" {
  ...
  [[ "$output" =~ "F1" ]] && [[ "$output" =~ "F10" ]]
}

@test "F11 → Enter on F3 switches client to console-3" {
  tmux -L test new-session -d -s console-3
  tmux -L test send-keys C-F11
  sleep 0.3
  tmux -L test send-keys 3 Enter
  sleep 0.3
  run tmux -L test display-message -p '#S'
  [ "$output" = "console-3" ]
}

@test "F11 → K on console-2 with confirm Y kills it" { ... }
@test "F11 → n creates console in lowest free slot" { ... }
@test "F11 → q closes popup, no manager pseudo-session" {
  tmux -L test send-keys C-F11
  sleep 0.3
  tmux -L test send-keys q
  sleep 0.3
  run tmux -L test list-sessions -F '#S'
  [[ ! "$output" =~ "manager" ]]
}
```

### 6. Updates from Design Review (2026-05-08)

#### D2 — Status legend in column header

The Status column header MUST include the icon-name pairs inline (single line, always visible — no separate legend block):

```
F-key  Status (●live ○idle ◐sleep ✖dead ·slot)  Console  Uptime  Last cmd  CPU%  Mem
```

Rationale: first-run users see `· slot` and don't know what it means. Inlining the legend in the header costs one line of width but eliminates the lookup.

#### D3 — Dead-state preview override

When selected row has `kind=dead`, the preview pane MUST NOT call `tmux capture-pane` (returns whatever was last there — often a stack trace mid-render, looks broken). Instead render a fixed message:

```
Session in error state.
  r — restart (kills + recreates)
  K — remove
```

Wave-3 preview script:
```bash
preview_cmd='
  kind=$(echo {} | cut -f2)
  s=$(echo {} | cut -f3)
  case "$kind" in
    slot) echo "(empty slot — press n to create)" ;;
    dead) printf "Session in error state.\n  r — restart\n  K — remove\n" ;;
    *)    tmux capture-pane -t "$s" -p -S -15 2>/dev/null ;;
  esac
'
```

#### D4 — 80-column degradation table

Manager popup MUST adapt columns to terminal width. Drop columns from the right:

| Width  | Columns shown |
|--------|---------------|
| ≥ 120  | F-key · Status · Console · Uptime · Last cmd · CPU% · Mem |
| 100–119| F-key · Status · Console · Uptime · Last cmd |
| 80–99  | F-key · Status · Console · Last cmd |
| < 80   | F-key · Status · Console |

Implementation: detect with `tput cols` at popup start, branch the format string.

#### D7 — Attached-session marker

The currently-attached session (where the user opened F11 from) MUST have a visible marker distinct from the cursor selector. Use `★` (filled star) right after the F-key:

```
F1   ●  live  console-1  …
F3 ★ ●  live  console-3  …    ← currently attached
F5   ●  live  console-5  …
```

`▸` cursor (selection) and `★` marker (attachment) coexist independently. Read attached session at popup start: `tmux display-message -p '#S'`.

#### Optional (apply if cheap): D5, D6, D8

- D5 — Drop "F12 toggle" claim; document `q`/`Esc` only.
- D6 — When `n` exits 5 (all slots used), show toast "All 10 F-slots in use. Free one with K to create new."
- D8 — On first F11 open per session, 3-second hint: "Press ? for keyboard shortcuts." Tracked via tmux user option `@ptty_f11_seen`.

---

## Acceptance

- [ ] `Ctrl+F11` opens a popup with title `pTTY Manager`
- [ ] All 10 F-slots displayed: F1–F10 with their kind (live/idle/sleep/dead/slot)
- [ ] Columns rendered: F-key · Status · Console · Uptime · Last cmd · CPU% · Mem
- [ ] Empty slots show `(empty — press n)` in console column
- [ ] **Single-key actions all work:**
  - `Enter` → switch to selected console
  - `K` (shift-k) → confirm dialog → on Y, kills selected
  - `r` → confirm dialog → on Y, restarts selected
  - `R` (shift-r) → prompt for new name → renames window
  - `n` → creates console in lowest free slot, refreshes list
  - `j`/`k` (or arrows) → move cursor
  - `1`–`9`,`0` → jump cursor to F1–F10 (where `0` = F10)
  - `/` → fuzzy filter
  - `?` → opens F12 help popup (nested ok)
  - `q`/`Esc` → close popup
- [ ] Live preview pane on right shows last 15 lines of selected console (or "empty slot" message)
- [ ] After every mutating action, list reloads (no manual refresh)
- [ ] Confirm dialog default is **No** (cursor on Cancel)
- [ ] Closing popup does NOT leave a `manager` pseudo-session in `tmux list-sessions`
- [ ] All `tests/smoke/popup-f11.bats` tests pass
- [ ] Visual: matches `f11-f12-redesign.html` mockup (colors, icons, alignment)
- [ ] Works on 80-column terminal width (columns degrade gracefully — drop CPU/Mem if needed)
- [ ] **D2:** Status column header inlines `(●live ○idle ◐sleep ✖dead ·slot)` legend
- [ ] **D3:** `dead` state preview shows fixed error message, not `capture-pane` output
- [ ] **D4:** Column degradation matches table for widths ≥120, 100–119, 80–99, <80
- [ ] **D7:** `★` marker on F-key column for currently-attached session, distinct from `▸` cursor

## Out of scope

- F12 help popup (Wave 4-A) — `?` just invokes it
- Plugin install (Wave 4-B)
- README GIF (Wave 5)
- Multi-select — v0.3
- Drag-to-reorder slots — v0.3

## Risks

- **fzf `--bind reload` behavior on different fzf versions** — pre-flight in install.sh requires fzf ≥ 0.30, but corner cases. Mitigation: bats test on fzf 0.30, 0.40, latest in CI matrix.
- **ANSI in fzf preview lines** — fzf needs `--ansi`. Mitigation: explicit `--ansi` flag, format strings tested.
- **80-col terminal** — Task 011 known issue. Mitigation: ANSI %20s column widths total 70 chars, fits 80. Drop CPU/Mem on `tput cols < 100`.
- **Nerd Font icons (●○◐✖·)** — these are Unicode, NOT Nerd-Font specific, so render on any UTF-8 terminal. Skipping fancy NF icons in v0.2 (Task 011 kept those out of scope).
- **Race: user presses Enter while reload runs** — fzf serializes; should be fine. Add bats test to confirm.

## Open questions to resolve in this wave

- Q-A: confirm `n` auto-picks lowest free without prompting. → **Yes** per PRD §10. Wave defaults this; revisit only if user feedback demands.
- Q-D: should `K` require typing the slot number? → **No.** Confirm dialog with default Cancel is enough. ADR-007 documents this.
