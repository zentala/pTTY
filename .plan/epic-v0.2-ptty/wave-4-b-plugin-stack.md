# Wave 4-B — Plugin stack (TPM + resurrect + continuum + which-key)

**Wave:** 4 (parallel with 4-A)
**Depends on:** Wave 1
**Worktree branch:** `feature/wave-4b-plugins`
**Architecture sections:** [§G plugin stack](ARCHITECTURE.md), [§H persistence model](ARCHITECTURE.md)
**Maps to legacy task:** [04-tasks/016-tmux-plugins-evaluation.md](../../04-tasks/016-tmux-plugins-evaluation.md)

---

## Why

"Persistent" branding requires that sessions survive **host reboot**, not just SSH disconnect. tmux alone doesn't do this — needs `tmux-resurrect` (save state) + `tmux-continuum` (auto-save scheduler).

Plus `tmux-which-key` (Wave 4-A) needs to be installed by the same mechanism. Plus TPM as plugin manager so install is one step, not three git clones.

## Starting state

After Wave 1:
- No `plugins/` directory.
- `tmux.conf` has no plugin loading.
- Reboot kills sessions (only `ptty.service` would restart tmux, but with empty state).

## Deliverable

### 1. `install.sh` — plugin bootstrap

Append to `install.sh` after the sed-template step:

```bash
# --- TPM bootstrap ---
TPM_DIR="$PTTY_DIR/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  echo "Installing TPM…"
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR" \
    || { echo "TPM clone failed; check network"; exit 1; }
fi

# --- Plugin install via TPM ---
# Start a temporary tmux session, source conf, run install_plugins, kill
echo "Installing plugins (resurrect, continuum, which-key)…"
tmux -L ptty-install start-server \;\
  source-file "$PTTY_DIR/tmux.conf" \;\
  run-shell "$TPM_DIR/bin/install_plugins" \;\
  kill-server 2>/dev/null || true

# Verify
for p in tmux-resurrect tmux-continuum tmux-which-key; do
  [ -d "$PTTY_DIR/plugins/$p" ] || { echo "WARN: $p not installed"; }
done
```

### 2. `tmux.conf` — plugin declarations

Append:

```tmux
# ----- Plugin manager -----
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'alberti42/tmux-which-key'

# ----- Resurrect config -----
set -g @resurrect-dir '#{PTTY_DIR}/state/resurrect'
set -g @resurrect-strategy-vim 'session'   # if Vim plugin Session.vim present
set -g @resurrect-strategy-nvim 'session'
set -g @resurrect-capture-pane-contents 'on'

# ----- Continuum config -----
set -g @continuum-restore 'on'              # auto-restore on tmux start
set -g @continuum-save-interval '15'        # minutes

# ----- which-key config (Wave 4-A) -----
set -g @which-key-position 'centered'
set -g @which-key-source-table 'root'

# ----- TPM init MUST be last line -----
run '#{PTTY_DIR}/plugins/tpm/tpm'
```

### 3. `ptty.service` — systemd unit

Replaces `tmux-console.service`:

```ini
[Unit]
Description=pTTY persistent tmux server
After=network.target

[Service]
Type=forking
User=%i
Environment="PTTY_DIR=%h/.ptty"
ExecStart=/usr/bin/tmux -f %h/.ptty/tmux.conf start-server \; new-session -d -s console-1
ExecStop=/usr/bin/tmux kill-server
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
```

Installed by `install.sh` (Linux only):

```bash
if command -v systemctl >/dev/null 2>&1 && [ -d "$HOME/.config/systemd/user" ]; then
  cp "$PTTY_DIR/ptty.service" "$HOME/.config/systemd/user/"
  systemctl --user daemon-reload
  systemctl --user enable ptty.service
  echo "✓ systemd unit installed (user-level). Start: systemctl --user start ptty"
fi
```

### 4. `03-architecture/decisions/adr-006-plugin-stack.md`

```markdown
# ADR-006: Plugin stack

**Status:** Accepted
**Date:** 2026-05-08

## Context

pTTY needs persistence across host reboot, not just SSH disconnect. F12 needs a help renderer. We can write everything ourselves or adopt established plugins.

## Decision

Adopt:
- TPM (manager)
- tmux-resurrect (save layout)
- tmux-continuum (auto-save scheduler, 15-min interval)
- tmux-which-key (F12 help)

Reject:
- tmux-sessionx — overlaps with own F11 (Q2 hybrid decision: own = brand)
- tmux-fzf, tmux-menus — overlap with sessionx/which-key
- extrakto, tmux-thumbs — out of scope; user can add post-install

## Consequences

- pTTY install installs 4 plugins via TPM. Adds ~5MB clone footprint.
- Resurrect + continuum cover host-reboot persistence story (matches "persistent" branding).
- which-key adoption tested via 1-day prototype (Wave 4-A); fallback `src/ui/help.sh` retained if mismatch.
- Future v0.3 plugins (e.g. extrakto) installable by user editing tmux.conf, no code change in pTTY.
```

### 5. Reboot smoke test — `tests/smoke/persistence.bats`

```bats
@test "continuum auto-save fires within 15 min" {
  tmux -L test new-session -d -s console-1
  tmux -L test new-window -t console-1
  sleep 15  # or trigger manually via continuum-save command
  [ -d "${PTTY_DIR}/state/resurrect" ]
  [ -n "$(ls "${PTTY_DIR}/state/resurrect/")" ]
}

@test "resurrect restores 2-window session after kill-server" {
  tmux -L test new-session -d -s console-1 -n one
  tmux -L test new-window -t console-1 -n two
  tmux -L test run-shell "${PTTY_DIR}/plugins/tmux-resurrect/scripts/save.sh"
  tmux -L test kill-server
  sleep 1
  tmux -L test new-session -d
  tmux -L test run-shell "${PTTY_DIR}/plugins/tmux-resurrect/scripts/restore.sh"
  run tmux -L test list-windows -t console-1 -F '#W'
  [[ "$output" =~ "one" ]] && [[ "$output" =~ "two" ]]
}
```

### 6. Updates from DX Review (2026-05-08)

#### X2 — TPM clone failure recovery hints

Replace the bare error in install.sh TPM bootstrap with the `ERROR / WHY / FIX` pattern from Wave 1:

```bash
git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR" || fail \
  "Could not clone TPM from github.com" \
  "No network, blocked by firewall, or git not installed" \
  "1. Check network: curl -I https://github.com
       2. Retry: ./install.sh
       3. Offline tarball: https://github.com/zentala/ptty/releases (v0.3+)"
```

Same pattern for plugin install verification — each missing plugin prints `ERROR / WHY / FIX` instead of a bare `WARN`.

#### X3 — Resurrect data outside `$PTTY_DIR`

Move resurrect save dir from `${PTTY_DIR}/state/resurrect/` to `${XDG_DATA_HOME:-$HOME/.local/share}/ptty/resurrect/`. Reason: `uninstall.sh` removes `$PTTY_DIR`; users who reinstall expect their saved layouts to come back.

```tmux
# tmux.conf — replace:
# set -g @resurrect-dir '#{PTTY_DIR}/state/resurrect'
set-environment -g PTTY_DATA_DIR "${XDG_DATA_HOME:-$HOME/.local/share}/ptty"
set -g @resurrect-dir '#{PTTY_DATA_DIR}/resurrect'
```

`install.sh` creates `$PTTY_DATA_DIR/resurrect/` with mode 700. `uninstall.sh` does NOT touch it (data preservation); add `--purge-data` flag if user wants total wipe.

Update [ARCHITECTURE.md §H](ARCHITECTURE.md) to match.

#### X7 — TPM dup note

If `~/.tmux/plugins/tpm` already exists (user's previous tmux setup), pTTY install does NOT touch it. We use our own isolated copy at `${PTTY_DIR}/plugins/tpm`. Document in README:

> pTTY ships its own TPM and plugin copies under `${PTTY_DIR}/plugins/`. This is intentional — pTTY's tmux conf shouldn't depend on whatever else you have configured at `~/.tmux/`. If you maintain a separate tmux setup, the two coexist.

---

## Acceptance

- [ ] `install.sh` clones TPM into `${PTTY_DIR}/plugins/tpm`
- [ ] `install.sh` triggers `install_plugins` and verifies all 4 plugins present
- [ ] Failure to clone any plugin prints WARN but doesn't abort install (graceful degrade)
- [ ] `tmux.conf` declares all 4 plugins via `@plugin`
- [ ] Continuum auto-saves to `${PTTY_DIR}/state/resurrect/` every 15 min (verified by file mtime check)
- [ ] After `kill-server` + restart, resurrect restores window layout
- [ ] `ptty.service` unit installed and enabled on Linux (user-level)
- [ ] `systemctl --user start ptty` starts the tmux server with conf loaded
- [ ] `~/.config/systemd/user/ptty.service` is the ONLY remaining unit (legacy `tmux-console.service` removed if present)
- [ ] ADR-006 written and committed
- [ ] All `tests/smoke/persistence.bats` tests pass
- [ ] **X2:** TPM clone failure prints `ERROR / WHY / FIX` recovery hints
- [ ] **X3:** Resurrect dir is `$XDG_DATA_HOME/ptty/resurrect/` (NOT `$PTTY_DIR/state/`); survives `uninstall.sh`
- [ ] **X7:** README documents isolated TPM copy at `$PTTY_DIR/plugins/`, doesn't conflict with user's `~/.tmux/plugins/tpm`

## Out of scope

- F12 binding to which-key (Wave 4-A)
- macOS launchd equivalent of systemd unit — v0.3 (LaunchAgent)
- BSD/illumos init systems — v1.0 if demand
- Custom continuum interval — user-configurable post-install via `set -g @continuum-save-interval`

## Risks

- **TPM install fails on offline machines** — Mitigation: install.sh has `--offline` flag that skips TPM and uses bundled tarball (v0.3 nice-to-have; v0.2 just errors clearly).
- **resurrect strategy for vim/nvim relies on user having Sessionx-style autosave** — Mitigation: documented in README "if you want vim sessions, install vim-obsession".
- **continuum auto-save during heavy tmux load** = lag — Mitigation: 15-min default is light. User can disable via `set -g @continuum-save-interval '0'`.
- **systemd user unit needs `loginctl enable-linger`** to survive logout — Mitigation: install.sh prints reminder; doesn't auto-run because requires sudo. Alternative: ship a cron wrapper.
- **which-key plugin not in TPM canon** (it's a community plugin) — Mitigation: TPM clones from any GitHub URL via `@plugin 'user/repo'`; works fine.
