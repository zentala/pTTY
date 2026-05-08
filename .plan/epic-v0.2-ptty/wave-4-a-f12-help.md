# Wave 4-A — F12 Help (which-key plugin + fallback)

**Wave:** 4 (parallel with 4-B)
**Depends on:** Wave 1
**Worktree branch:** `feature/wave-4a-f12-help`
**Architecture sections:** [§F popup contract](ARCHITECTURE.md), [§G plugin stack](ARCHITECTURE.md)
**Mockup:** [`02-planning/mockups/f11-f12-redesign.html`](../../02-planning/mockups/f11-f12-redesign.html) §F12
**Maps to legacy task:** [04-tasks/015-f12-which-key-help.md](../../04-tasks/015-f12-which-key-help.md)

---

## Why

Today F12 is a static `cat <<EOF` + `sleep infinity` in a parallel `help` session. Per Q2 decision (hybrid), F12 = **adopt `alberti42/tmux-which-key`** plugin, NOT own implementation. Plus a fallback `src/ui/help.sh` for environments where the plugin failed to install.

## Starting state

After Wave 1:
- `src/ui/help.sh` exists (renamed from `help-reference.sh`) — still the static text + `sleep infinity`.
- F12 binding goes to `display-popup -E ${PTTY_DIR}/src/ui/help.sh`.
- TPM not yet installed (Wave 4-B does that).

## Deliverable

### 1. Annotation pass on `tmux.conf`

Add structured comments to every binding so which-key can group/describe them:

```tmux
# @group: navigation @desc: Jump to console 1
bind-key -n C-F1 switch-client -t console-1
# @group: navigation @desc: Jump to console 2
bind-key -n C-F2 switch-client -t console-2
# ...
# @group: navigation @desc: Previous console
bind-key -n C-Left switch-client -p
# @group: navigation @desc: Next console
bind-key -n C-Right switch-client -n

# @group: management @desc: Open Manager popup
bind-key -n C-F11 display-popup -E -w 90% -h 85% '#{PTTY_DIR}/src/ui/manager.sh'
# @group: management @desc: Restart current console (with confirm)
bind-key -n C-r display-popup -E -w 70 -h 13 '#{PTTY_DIR}/src/actions/restart.sh'
# @group: management @desc: Detach client (sessions keep running)
bind-key -n C-d run-shell '#{PTTY_DIR}/src/actions/detach.sh'

# @group: display @desc: Open Help popup
bind-key -n C-F12 display-popup -E -w 80% -h 80% '#{PTTY_DIR}/src/ui/help.sh'
# @group: display @desc: Show shortcuts cheat sheet
bind-key -n C-h display-popup -E -w 50 -h 12 '#{PTTY_DIR}/src/ui/shortcuts-popup.sh'
```

### 2. which-key plugin config

Append to `tmux.conf` (after TPM init line — set up in Wave 4-B):

```tmux
# F12 → which-key popup, scoped to root key table (no prefix needed)
set -g @which-key-position 'centered'
set -g @which-key-width '80%'
set -g @which-key-height '80%'
set -g @which-key-source-table 'root'

# Bind F12 to which-key invocation
bind-key -n C-F12 run-shell "#{PTTY_DIR}/plugins/tmux-which-key/which-key.tmux open"
```

(Exact keys depend on the plugin's API — verify during 1-day prototype before committing the full pass.)

### 3. `src/ui/help.sh` — graceful fallback

If which-key plugin missing (TPM hasn't run, or plugin failed to install), this fallback renders bindings in a popup using the same annotation parser. No more `sleep infinity`.

```bash
#!/usr/bin/env bash
set -euo pipefail

PTTY_DIR="${PTTY_DIR:-$HOME/.ptty}"

# Header
printf '\033[1;36m  pTTY Help — Keybindings\033[0m\n\n'

# Parse tmux.conf for @group / @desc annotations
awk '
  /^# @group:/ {
    match($0, /@group: ([^ ]+)/, g)
    match($0, /@desc: (.*)/, d)
    group=g[1]; desc=d[1]
    getline
    if ($0 ~ /^bind-key/) {
      match($0, /-n ([^ ]+)/, k)
      key=k[1]
      groups[group] = groups[group] sprintf("    %-15s  %s\n", key, desc)
    }
  }
  END {
    for (g in groups) {
      printf "  \033[1;33m%s\033[0m\n%s\n", toupper(g), groups[g]
    }
  }
' "${PTTY_DIR}/tmux.conf"

printf '\n  \033[2mPress q or Esc to close\033[0m\n'

# Wait for q/Esc, then exit (popup -E closes on exit)
while IFS= read -rsn1 c; do
  case "$c" in q|$'\e') break ;; esac
done
```

### 4. Plugin prototype day (before committing full pass)

Before doing the full annotation pass on `tmux.conf` (~30 bindings), spend **half a day**:

1. Install which-key in a fresh test config
2. Verify it parses our annotation format (or what its native format is)
3. Verify popup renders well on 80-col / 200-col terminals
4. If misfit → fallback `src/ui/help.sh` becomes the **primary** implementation, plugin is dropped

Document outcome in `.plan/epic-v0.2-ptty/IMPRO.md` (created if needed).

### Tests — `tests/smoke/popup-f12.bats`

```bats
@test "F12 opens popup (no help pseudo-session)" {
  tmux -L test send-keys C-F12
  sleep 0.5
  run tmux -L test list-sessions -F '#S'
  [[ ! "$output" =~ "help" ]]
}

@test "F12 popup mentions F1, F11 bindings" {
  tmux -L test send-keys C-F12
  sleep 0.5
  run tmux -L test capture-pane -p
  [[ "$output" =~ "F1" ]] && [[ "$output" =~ "F11" ]]
}

@test "F12 popup closes on q" { ... }
@test "F12 popup closes on Esc" { ... }
@test "F12 toggles: pressing F12 while open closes it" { ... }

@test "Fallback help.sh works when plugin missing" {
  rm -rf "${PTTY_DIR}/plugins/tmux-which-key"
  # F12 binding in this case points to help.sh
  ...
}
```

## Acceptance

- [ ] **Plugin prototype day done first** — decision recorded: adopt which-key OR drop to fallback-only
- [ ] If plugin adopted: F12 opens which-key popup, all bindings visible, grouped, searchable
- [ ] If plugin dropped: F12 opens `src/ui/help.sh` popup with same content
- [ ] **No `help` pseudo-session** in `tmux list-sessions`
- [ ] **No `sleep infinity`** in any source file (verified by `grep`)
- [ ] F12 closes on `q`, `Esc`, and re-pressing F12 (toggle)
- [ ] Bindings shown match what's actually in `tmux.conf` — adding a new annotated binding makes it appear in F12 without code changes
- [ ] All `tests/smoke/popup-f12.bats` tests pass
- [ ] Renders on 80-col and 200-col terminals (no horizontal cut-off)

## Out of scope

- TPM / resurrect / continuum install (Wave 4-B)
- Per-context help (different help in manager popup vs. shell) — v0.3
- F12 inline tutorial — v1.0

## Risks

- **which-key plugin annotation format mismatch** — Mitigation: prototype day first, ADR-006 records decision. Fallback already implemented.
- **`tmux list-keys -N` natural-language descriptions** are tmux-3.4+ only — Mitigation: parse `tmux.conf` directly via awk (tmux-version-independent).
- **Annotated comments lost on `tmux source-file`** — comments stay in the file but tmux doesn't care about them; awk reads file directly. OK.
- **F12 toggle (close on re-press)** — `display-popup -E` doesn't natively support toggle; need wrapper that detects "is popup open" via a state file. Or accept that re-press is no-op when popup focused (terminal swallows the key). Test in prototype day.
