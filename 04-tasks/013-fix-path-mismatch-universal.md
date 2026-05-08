# Task 013: Fix Path Mismatch — Universal Install

**Status:** 🔴 BLOCKER for v0.2 release
**Priority:** CRITICAL
**Created:** 2026-05-08

---

## Problem

`tmux.conf` references `~/.vps/sessions/src/...` (legacy install location) but the repo lives in `~/.tmux-persistent-console/` (and after Task 012: `~/.ptty/`). Result:

- F11 (Manager) — broken, `run-shell` silently fails
- F12 (Help) — broken
- Ctrl+H (shortcuts popup) — broken
- Ctrl+R (restart confirm) — broken
- `source-file` for status bar — broken

Verified on current install (tmux 3.5a) — none of these keys do anything.

## Solution: env-var templating

1. **Top of `tmux.conf`:**
   ```tmux
   set-environment -g PTTY_DIR "__PTTY_DIR__"
   ```

2. **Replace every hardcoded path:**
   ```tmux
   # before
   '~/.vps/sessions/src/manager-menu.sh'
   # after
   '#{PTTY_DIR}/src/mission-control.sh'
   ```

3. **`install.sh` templates the value:**
   ```bash
   PTTY_DIR="${PTTY_DIR:-$HOME/.ptty}"
   sed "s|__PTTY_DIR__|$PTTY_DIR|g" "$REPO/tmux.conf" > "$PTTY_DIR/tmux.conf"
   ```

4. **Allow `PTTY_DIR` env override** so dev can `PTTY_DIR=$PWD ./install.sh` for local testing.

## Files to update

- [ ] `tmux.conf` — top-of-file `set-environment`, replace 5 hardcoded paths
- [ ] `install.sh` — sed-template, accept `PTTY_DIR` env, default to `~/.ptty`
- [ ] `uninstall.sh` — read same env, remove templated dir
- [ ] `setup.sh` — same logic
- [ ] All `*.sh` in `src/` — if any reference `$HOME/.vps/...` directly, switch to `${PTTY_DIR:-$HOME/.ptty}`
- [ ] Rename `manager-menu.sh` referenced in conf → use actual file `mission-control.sh` (or rename the file)

## Acceptance

- Fresh `git clone … && PTTY_DIR=/tmp/ptty-test ./install.sh` → all keys work
- F11, F12, Ctrl+H, Ctrl+R all responsive after `tmux source ~/.tmux.conf`
- No string `~/.vps/sessions` left in repo (`grep -r "vps/sessions" .` → empty)

## Out of scope

- Migration from existing `~/.vps/sessions/...` install (covered by Task 012 rename)
