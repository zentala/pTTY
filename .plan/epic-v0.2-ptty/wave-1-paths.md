# Wave 1 — Path universality (`PTTY_DIR` env-var)

> ✅ **Closed early in v0.1.3** (2026-05-23). The underlying bug (stale
> `~/.vps/sessions/...` paths in `tmux.conf` + scripts) was resolved by
> a global sed in commit `5982c07` and the install-time guardrails added
> in `5bc98bc`. We didn't introduce a `PTTY_DIR` env-var — the simpler
> fix (just write the right path everywhere) was enough. Keeping this
> file as historical context; if `PTTY_DIR` is ever needed (e.g. for
> users who want a non-default install location), re-open as a separate
> task.

**Wave:** 1 (foundation, BLOCKER for everything)
**Depends on:** none
**Worktree branch:** `feature/wave-1-ptty-dir`
**Architecture section:** [ARCHITECTURE.md §E](ARCHITECTURE.md)
**Maps to legacy task:** [04-tasks/013-fix-path-mismatch-universal.md](../../04-tasks/013-fix-path-mismatch-universal.md)

---

## Why

`tmux.conf` references `~/.vps/sessions/src/...` (legacy, never installed at this location in current repo). Result on any machine running this repo today:

- F11 (Manager) — `run-shell` silently fails
- F12 (Help) — silently fails
- Ctrl+H (shortcuts popup) — silently fails
- Ctrl+R (restart confirm) — silently fails
- `source-file` for status bar — silently fails

This is the v0.2 ship-blocker. Without this wave, no F11/F12 demo possible, no testing possible, the epic stalls.

## Starting state

- `tmux.conf:25` — `source-file ~/.vps/sessions/src/status-format-v4.tmux`
- `tmux.conf:51` — `… '~/.vps/sessions/src/manager-menu.sh' …` (file does not exist anywhere)
- `tmux.conf:54` — `… '~/.vps/sessions/src/help-reference.sh' …`
- `tmux.conf:61` — Ctrl+H popup script reference
- `tmux.conf:64` — Ctrl+R popup script reference
- Repo files actually live at `~/.tmux-persistent-console/src/...`
- Filename mismatch: conf says `manager-menu.sh`, repo has `mission-control.sh`

## Deliverable

### 1. tmux.conf — env-var-driven paths

```tmux
# Top of tmux.conf, before any binding:
set-environment -g PTTY_DIR "__PTTY_DIR__"

# Replace every hardcoded path:
source-file '#{PTTY_DIR}/src/ui/status-bar.tmux'
bind-key -n C-F11 display-popup -E -w 90% -h 85% '#{PTTY_DIR}/src/ui/manager.sh'
bind-key -n C-F12 display-popup -E -w 80% -h 80% '#{PTTY_DIR}/src/ui/help.sh'
bind-key -n C-h   display-popup -E -w 50  -h 12  '#{PTTY_DIR}/src/ui/shortcuts-popup.sh'
bind-key -n C-r   display-popup -E -w 70  -h 13  '#{PTTY_DIR}/src/actions/restart.sh'
```

> **Note:** Wave 1 changes paths AND eliminates the tmux 3.1 fallback (per Q4 decision). The `if tmux display-popup -h 1 'echo test' …` detection is removed; install.sh enforces tmux ≥ 3.2.

> **Note 2:** Manager script is renamed `mission-control.sh` → `src/ui/manager.sh` in this wave (file move). Other scripts move into `src/ui/` to match target layout (Wave 2 relocates the rest).

### 2. install.sh — sed-template

```bash
#!/usr/bin/env bash
set -euo pipefail

PTTY_DIR="${PTTY_DIR:-$HOME/.ptty}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Pre-flight
command -v tmux >/dev/null || { echo "tmux not installed"; exit 1; }
tmux_ver=$(tmux -V | grep -oE '[0-9]+\.[0-9]+' | head -1)
if [ "$(printf '%s\n' "3.2" "$tmux_ver" | sort -V | head -1)" != "3.2" ]; then
  cat <<EOF
ERROR: pTTY requires tmux >= 3.2 (you have $tmux_ver).
Upgrade hints:
  Debian/Ubuntu: sudo apt install -t bullseye-backports tmux  # or build from source
  RHEL/Fedora:   sudo dnf install tmux
  macOS:         brew upgrade tmux
EOF
  exit 1
fi

command -v fzf >/dev/null || { echo "fzf not installed (need >= 0.30)"; exit 1; }

# Copy + template
mkdir -p "$PTTY_DIR"
rsync -a --delete \
  --exclude='.git' --exclude='.plan' --exclude='02-planning' \
  --exclude='03-architecture' --exclude='04-tasks' --exclude='tests' \
  "$REPO_DIR/" "$PTTY_DIR/"

sed -i.bak "s|__PTTY_DIR__|$PTTY_DIR|g" "$PTTY_DIR/tmux.conf"
rm -f "$PTTY_DIR/tmux.conf.bak"

# Symlink for legacy compat (one release cycle, removed in v0.3)
[ -e "$HOME/.tmux-persistent-console" ] || ln -s "$PTTY_DIR" "$HOME/.tmux-persistent-console"

echo "✓ pTTY installed at $PTTY_DIR"
echo "  Add to your ~/.tmux.conf or run: tmux -f $PTTY_DIR/tmux.conf"
```

### 3. CI guard

`.github/workflows/lint.yml` step:

```yaml
- name: No legacy paths
  run: |
    if grep -rE 'vps/sessions|tmux-persistent-console/src' \
       --include='*.sh' --include='*.tmux' --include='*.conf' \
       src/ tmux.conf install.sh uninstall.sh setup.sh 2>/dev/null; then
      echo "ERROR: legacy hardcoded path found"; exit 1
    fi
```

Pre-commit hook (`.git/hooks/pre-commit`) does the same check locally.

### 4. File renames / moves

| From | To |
|------|----|
| `src/mission-control.sh` | `src/ui/manager.sh` |
| `src/help-reference.sh` | `src/ui/help.sh` |
| `src/shortcuts-popup.sh` | `src/ui/shortcuts-popup.sh` |
| `src/status-format-v4.tmux` | `src/ui/status-bar.tmux` |
| `src/restart-confirm.sh` | `src/actions/restart.sh` (Wave 2 finishes the split) |

Use `git mv` to preserve history. Old `src/click-session.sh`, `src/console-help-old-backup.sh`, `src/help-console-old-backup.sh`, `src/status-bar-legacy.sh` deleted (legacy, unused).

### 5. uninstall.sh — symmetric removal

```bash
#!/usr/bin/env bash
set -euo pipefail
PTTY_DIR="${PTTY_DIR:-$HOME/.ptty}"
[ -d "$PTTY_DIR" ] || { echo "Not installed at $PTTY_DIR"; exit 0; }
[ -L "$HOME/.tmux-persistent-console" ] && rm "$HOME/.tmux-persistent-console"
rm -rf "$PTTY_DIR"
echo "✓ pTTY removed from $PTTY_DIR"
echo "  Sessions kept. Use --purge to also kill them. (TODO Wave 5)"
```

### 6. Updates from DX Review (2026-05-08)

#### X2 — Failure-mode recovery hints in install.sh

Every `exit 1` in `install.sh` MUST print `ERROR / WHY / FIX` triplet, not just one line. Pattern:

```bash
fail() {
  cat >&2 <<EOF
ERROR: $1
WHY:   $2
FIX:   $3
EOF
  exit 1
}

# Examples:
[ "$tmux_ver_ok" ] || fail \
  "tmux version $tmux_ver is too old (need ≥ 3.2)" \
  "Your distro ships an older tmux" \
  "Debian/Ubuntu: sudo apt install -t bullseye-backports tmux
       RHEL/Fedora:   sudo dnf install tmux
       macOS:         brew upgrade tmux"

command -v fzf >/dev/null || fail \
  "fzf not installed" \
  "fzf is required for the F11 popup list" \
  "Debian/Ubuntu: sudo apt install fzf
       RHEL/Fedora:   sudo dnf install fzf
       macOS:         brew install fzf"
```

Apply to: tmux check, fzf check, git availability, write-permission to PTTY_DIR, sed failure.

---

## Acceptance

- [ ] `git grep -E 'vps/sessions'` returns empty across the repo (excluding `.plan/`, `02-planning/`, `03-architecture/`, `04-tasks/` docs which legitimately reference the legacy path in migration notes)
- [ ] Fresh test: `PTTY_DIR=/tmp/ptty-test ./install.sh` succeeds
- [ ] In a fresh tmux: `tmux -f /tmp/ptty-test/tmux.conf` starts, `Ctrl+F11` opens manager.sh popup (renders SOMETHING; functionality is Wave 3, but the popup must appear)
- [ ] `Ctrl+F12` opens help.sh popup
- [ ] `Ctrl+H` opens shortcuts popup
- [ ] CI guard active: introducing `~/.vps/sessions/foo` to any source file fails the build
- [ ] `install.sh` rejects tmux < 3.2 with copy-paste upgrade hint
- [ ] `install.sh` rejects fzf < 0.30 with copy-paste upgrade hint
- [ ] Symlink `~/.tmux-persistent-console → $PTTY_DIR` created for backwards compat
- [ ] `git mv` used for renames (history preserved); `git log --follow src/ui/manager.sh` shows previous mission-control.sh commits
- [ ] **X2:** Every `exit 1` in `install.sh` uses the `ERROR / WHY / FIX` pattern with copy-paste recovery commands

## Out of scope (do NOT do here)

- F11 popup actual functionality (Wave 3)
- F12 which-key plugin (Wave 4-a)
- TPM / resurrect / continuum install (Wave 4-b)
- GitHub repo rename to `ptty` (Wave 5)
- README rewrite (Wave 5)
- Modular split of `manager.sh` (Wave 2 + Wave 3)

## Risks

- **rsync --exclude wrong** → installer ships planning docs to `$PTTY_DIR`. Mitigation: explicit exclude list, smoke-test by `find $PTTY_DIR -name '*.md' | grep -E 'wave-|PRD|REVIEW'` returns empty.
- **Symlink loop** if user already has `~/.tmux-persistent-console` directory (not symlink). Mitigation: install.sh checks, prints migration notice, refuses overwrite without `--migrate` flag.
- **Path with spaces** breaks sed delimiter. Mitigation: `sed` uses `|` as separator (already in code); add test with `PTTY_DIR="/tmp/path with spaces/ptty"`.
