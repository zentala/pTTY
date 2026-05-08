# Wave 5 — Rebrand to pTTY + v0.2 Release

**Wave:** 5 (final, sequential after Wave 4)
**Depends on:** Wave 1, 2, 3, 4
**Worktree branch:** `feature/wave-5-release`
**Architecture sections:** [§B file layout](ARCHITECTURE.md), all release-level concerns
**Maps to legacy task:** [04-tasks/012-rename-repo-to-ptty.md](../../04-tasks/012-rename-repo-to-ptty.md), [04-tasks/004-testing-framework.md](../../04-tasks/004-testing-framework.md)

---

## Why

Per Q5: full pTTY rebrand happens in v0.2 (first public release = cheapest rename moment). This wave consolidates: GitHub repo rename, README rewrite with GIFs, GitHub Pages, CHANGELOG, install one-liner, bats CI smoke. After this wave, **users can `curl | bash` and have working pTTY**.

## Starting state

After Waves 1–4:
- All code uses `pTTY` / `ptty` naming internally (popups say "pTTY Manager", etc.)
- Repo on GitHub still named `tmux-persistent-console`
- README still says "Persistent Console v1.0.0" in places
- No CHANGELOG
- No GitHub Pages
- No CI workflow
- No published install one-liner

## Deliverable

### 1. GitHub repo rename

```bash
# On github.com via web UI or:
gh repo rename ptty -R zentala/tmux-persistent-console
```

GitHub auto-redirects old URLs (clones, README links, etc.) for the foreseeable future.

Update local clone:

```bash
cd ~/.tmux-persistent-console
git remote set-url origin https://github.com/zentala/ptty.git
```

### 2. README rewrite

Full rewrite. Structure:

```markdown
<h1 align="center">pTTY</h1>
<p align="center"><em>persistent pseudo-TTY — SSH disconnect-proof terminal sessions with a real UI</em></p>

<p align="center">
  <a href="https://github.com/zentala/ptty/releases"><img src="…version-badge…"></a>
  <a href="https://github.com/zentala/ptty/actions"><img src="…ci-badge…"></a>
</p>

## What

[F11 manager GIF — 30s loop]

[F12 help GIF — 15s loop]

pTTY is a thin UX layer on top of tmux that gives you:
- Numbered console slots (F1–F10), one keypress to jump
- F11 popup with all consoles, live status, single-key kill/restart/rename
- F12 popup with auto-generated help
- Sessions survive SSH disconnect AND host reboot

## Install

```bash
curl -sSL https://ptty.zentala.io/install | bash
```

Or:

```bash
git clone https://github.com/zentala/ptty ~/.ptty
~/.ptty/install.sh
```

**Requirements:** tmux ≥ 3.2, fzf ≥ 0.30, bash 4+. Tested on Debian 12+, Ubuntu 22.04+, RHEL 9+, macOS 12+.

## Usage

| Key | Action |
|-----|--------|
| F1–F10 | Jump to console N |
| F11 | Manager popup |
| F12 | Help popup |
| Ctrl+← / Ctrl+→ | Prev / next console |
| Ctrl+R | Restart current console |
| Ctrl+D | Detach (sessions keep running) |

[…rest of README…]

## Migrating from tmux-persistent-console

[…CHANGELOG migration section excerpt…]
```

### 3. README GIFs (the launch story)

Use [`vhs`](https://github.com/charmbracelet/vhs) for reproducible GIFs:

```bash
# examples/demo-f11.tape
Output examples/f11-demo.gif
Set FontSize 14
Set Width 1200
Set Height 800
Set Theme "Dracula"

Type "tmux"
Enter
Sleep 1s
Type "vim build.log"
Sleep 500ms
Ctrl+F11
Sleep 1s
Down Down
Sleep 500ms
Type "K"
Sleep 1s
Type "y"
Sleep 1s
Type "n"
Sleep 1s
Escape
```

Same for F12. Both committed under `examples/` and embedded in README.

### 4. GitHub Pages — `ptty.zentala.io`

`docs-site/index.html` (or use astro/jekyll if you prefer):

- Hero: tagline + animated F11 GIF
- Install one-liner copy-button
- Feature grid: persistence / popup UI / plugins
- Quick start
- Link to GitHub repo

Configure `gh-pages` branch + custom domain in repo settings. CNAME file:

```
ptty.zentala.io
```

### 5. `install` script published as one-liner

`docs-site/install` is just a redirect / proxy to the repo's `install.sh`:

```sh
#!/bin/sh
# Curl-bashable installer
exec /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/zentala/ptty/master/install.sh)"
```

Or simpler: GitHub Pages serves `install.sh` directly, README points there.

### 6. CHANGELOG.md

```markdown
# Changelog

## v0.2.0 — 2026-XX-XX — "pTTY Launch"

First public release. Project renamed from `tmux-persistent-console` to `pTTY`.

### Added
- F11 popup Manager with live console status, single-key actions (Enter/K/r/R/n)
- F12 popup Help with which-key plugin (auto-generated from current bindings)
- Persistence across host reboot via tmux-resurrect + tmux-continuum
- Universal install via `PTTY_DIR` env-var
- One-liner installer: `curl -sSL https://ptty.zentala.io/install | bash`
- systemd user unit `ptty.service` for boot autostart
- bats test framework with unit + smoke coverage

### Changed
- Repo name: `tmux-persistent-console` → `ptty`
- Default install path: `~/.tmux-persistent-console` → `~/.ptty`
- F-slots extended from 7 to 10 (F1–F10)
- F11/F12 are now popups, not parallel sessions
- Manager actions: single-key (was: two-step menu)

### Removed
- Hardcoded `~/.vps/sessions/` paths
- `manager` and `help` pseudo-sessions
- `sleep infinity` in help renderer
- Two-step fzf flow in F11

### Migration from tmux-persistent-console

If you had the old install:

```bash
# Backup any custom changes:
cp -r ~/.tmux-persistent-console ~/.tmux-persistent-console.bak

# Run the new installer (sets up ~/.ptty + symlinks ~/.tmux-persistent-console):
curl -sSL https://ptty.zentala.io/install | bash

# After verifying everything works, remove the symlink and backup:
rm ~/.tmux-persistent-console
rm -rf ~/.tmux-persistent-console.bak
```

The legacy symlink is kept for one release cycle (v0.2.x). It will be removed in v0.3.

### Known limitations
- macOS launchd unit not yet shipped (use `~/.zshrc` to auto-start tmux for now)
- Windows / WSL: works under WSL2; native Windows not supported
- tmux 4.0 not yet tested
```

### 7. CI — `.github/workflows/ci.yml`

```yaml
name: CI
on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: sudo apt install -y shellcheck
      - run: shellcheck src/**/*.sh install.sh uninstall.sh
      - name: No legacy paths
        run: |
          if grep -rE 'vps/sessions|tmux-persistent-console/src' \
             --include='*.sh' --include='*.tmux' --include='*.conf' \
             src/ tmux.conf install.sh uninstall.sh 2>/dev/null; then
            echo "ERROR: legacy hardcoded path found"; exit 1
          fi

  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        tmux: ["3.2", "3.5", "latest"]
    steps:
      - uses: actions/checkout@v4
      - name: Install deps
        run: |
          sudo apt install -y fzf bats
          # Install tmux ${{ matrix.tmux }}
          ...
      - run: bats tests/unit
      - run: bats tests/smoke

  install-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: PTTY_DIR=/tmp/ptty-test ./install.sh
      - run: tmux -f /tmp/ptty-test/tmux.conf list-keys | grep -q "C-F11"
```

### 8. Cleanup

Old files to remove:

```
src/click-session.sh                        # legacy
src/console-help-old-backup.sh              # legacy
src/help-console-old-backup.sh              # legacy
src/help-console.sh                         # legacy
src/status-bar-legacy.sh                    # legacy
src/status-format-v3.tmux                   # legacy
src/connect.sh                              # legacy
src/restart-session.sh                      # subsumed by actions/restart.sh
src/safe-exit.sh                            # subsumed by actions/detach.sh
src/setup.sh                                # subsumed by install.sh
src/theme-config.sh                         # legacy
src/preview-ux.sh                           # mockup script, dev-time
src/ux-design-workshop.sh                   # mockup script
src/mission-control.sh                      # split into ui/manager + actions/* in Wave 2
src/tmux-console.service                    # replaced by ptty.service
```

Use `git rm`, document in CHANGELOG.

### 9. GitHub Release

```bash
gh release create v0.2.0 \
  --title "v0.2.0 — pTTY Launch" \
  --notes-file CHANGELOG.md \
  --target master
```

### 10. Updates from DX Review (2026-05-08)

#### X1 — `git clone` install alternative documented

README presents two install options side-by-side, NOT just `curl | bash`:

```markdown
## Install

### Quick (one-liner)

    curl -sSL https://ptty.zentala.io/install | bash

### Inspect-first (recommended for security-conscious users)

    git clone https://github.com/zentala/ptty
    cd ptty
    less install.sh   # inspect before running
    ./install.sh
```

Note in v0.2 release notes: GPG-signed install + checksum file is on roadmap for v0.3.

#### X4 — `bin/ptty-doctor` diagnostic command

Ship a single command that dumps full state for issue reports. `bin/ptty-doctor`:

```bash
#!/usr/bin/env bash
set -euo pipefail
PTTY_DIR="${PTTY_DIR:-$HOME/.ptty}"

echo "pTTY version:    $(cat "$PTTY_DIR/VERSION" 2>/dev/null || echo unknown)"
echo "PTTY_DIR:        $PTTY_DIR"
echo "PTTY_DATA_DIR:   ${XDG_DATA_HOME:-$HOME/.local/share}/ptty"
echo
echo "tmux version:    $(tmux -V) $(tmux -V | grep -qE '3\.[2-9]|[4-9]' && echo '(OK, ≥3.2)' || echo '(TOO OLD)')"
echo "fzf version:     $(fzf --version | head -1) $(fzf --version | grep -qE '0\.([3-9][0-9]|[4-9])' && echo '(OK, ≥0.30)' || echo '(TOO OLD)')"
echo "bash version:    $BASH_VERSION"
echo
echo "Plugins:"
for p in tpm tmux-resurrect tmux-continuum tmux-which-key; do
  if [ -d "$PTTY_DIR/plugins/$p" ]; then
    echo "  $p: ✓ installed"
  else
    echo "  $p: ✗ MISSING"
  fi
done
echo
if command -v systemctl >/dev/null 2>&1; then
  echo "systemd unit:    $(systemctl --user is-enabled ptty.service 2>/dev/null || echo 'not installed')"
  echo "                 $(systemctl --user is-active ptty.service 2>/dev/null || echo 'inactive')"
fi
echo
echo "Recent log (last 10 lines from $XDG_CACHE_HOME/ptty/log):"
tail -n 10 "${XDG_CACHE_HOME:-$HOME/.cache}/ptty/log" 2>/dev/null || echo "  (no log)"
```

Symlinked to `$PATH`-accessible name during install (e.g. `~/.local/bin/ptty-doctor` if `~/.local/bin` is in PATH).

Issue template (`.github/ISSUE_TEMPLATE/bug.yml`) asks for `ptty-doctor` output as first field.

#### X5 — macOS reality check

Wave 5 ships **without** boot-autostart on macOS. Update README install section:

```markdown
### macOS specifics

Boot-autostart on macOS requires a LaunchAgent — coming in v0.3.
For now, add to your `~/.zshrc` or `~/.bash_profile`:

    [ -z "$TMUX" ] && tmux -f ~/.ptty/tmux.conf attach 2>/dev/null \
      || tmux -f ~/.ptty/tmux.conf new-session
```

CI matrix MUST include `macos-latest` runner; minimum criterion: `install.sh` succeeds, F11 popup opens.

PRD §6 update: change "macOS 12+" to "macOS 12+ (manual shell-rc autostart; LaunchAgent in v0.3)".

#### X6 — Makefile (optional)

```make
.PHONY: dev test lint clean install-dev help

help:
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | awk -F':.*##' '{printf "  %-15s %s\n", $$1, $$2}'

dev:           ## Run tmux with current repo conf in named server "ptty-dev"
	tmux -L ptty-dev -f $$PWD/tmux.conf

test:          ## Run all bats tests
	bats tests/unit tests/smoke

lint:          ## shellcheck + grep for legacy paths
	shellcheck src/**/*.sh install.sh uninstall.sh
	! grep -rE 'vps/sessions' --include='*.sh' --include='*.tmux' --include='*.conf' src/ tmux.conf

clean:         ## Kill the dev tmux server
	tmux -L ptty-dev kill-server 2>/dev/null || true

install-dev:   ## Install in-place from current clone
	PTTY_DIR=$$PWD ./install.sh
```

---

## Acceptance

- [ ] `gh repo view zentala/ptty` succeeds (rename done)
- [ ] Old `gh repo view zentala/tmux-persistent-console` redirects (GitHub auto)
- [ ] README has 2 GIFs (F11, F12) reproducible from `examples/*.tape` via `vhs`
- [ ] `ptty.zentala.io` resolves to GitHub Pages site
- [ ] `curl -sSL https://ptty.zentala.io/install | bash` installs pTTY in <60s on a clean Debian 12 VM
- [ ] CHANGELOG.md complete with migration section
- [ ] CI workflow runs on PR and push, all green
- [ ] CI matrix tests tmux 3.2, 3.5, latest on Ubuntu
- [ ] `shellcheck` clean across all shell scripts
- [ ] No legacy files left (per cleanup list above)
- [ ] `git log --follow` works on renamed files (history preserved via Wave 1 `git mv`)
- [ ] GitHub Release v0.2.0 published with notes
- [ ] Tweet / blog post ready (out of scope for code, but call it out)
- [ ] **X1:** README documents both `curl | bash` and `git clone + inspect + ./install.sh` install paths
- [ ] **X4:** `bin/ptty-doctor` command exists, prints version/path/plugin/log state; symlinked to `~/.local/bin/ptty-doctor` by install.sh
- [ ] **X4:** `.github/ISSUE_TEMPLATE/bug.yml` requests `ptty-doctor` output as first field
- [ ] **X5:** README includes macOS-specific autostart snippet; CI matrix includes `macos-latest` runner
- [ ] **X5:** PRD §6 updated to reflect "macOS shell-rc autostart, LaunchAgent in v0.3"
- [ ] **X6 (optional):** `Makefile` with `dev`, `test`, `lint`, `clean`, `install-dev` targets

## Out of scope

- macOS Homebrew tap — v0.3
- Debian package — v0.3+
- Snap / Flatpak — never (overkill)
- v0.2.1 hotfix release process — define when first hotfix needed
- Telemetry — never (privacy stance)

## Risks

- **GIF size > GitHub's 10MB limit per file** — Mitigation: trim to 30s loop, optimize with `gifsicle -O3`, or host externally on imgur.
- **GitHub Pages CNAME propagation lag** — Mitigation: do this 24h before announcing.
- **Install one-liner via curl|bash trust concerns** — Mitigation: README documents `git clone + inspect + run` alternative.
- **Old links to `tmux-persistent-console` cached in search engines** — accept; redirects work; over time SEO catches up.
- **Existing user breaks on `~/.vps/sessions/` removal** — Mitigation: install.sh detects + symlinks + prints migration banner.
