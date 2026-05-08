# Task 012: Rename Repo to pTTY (persistent TTY)

**Status:** 📋 BACKLOG (pre-v0.2 release)
**Priority:** MEDIUM (branding — do before public release)
**Created:** 2026-05-08

---

## Goal

Rename project from `tmux-persistent-console` to **pTTY** (persistent TTY). Shorter, memorable, technically accurate (TTY = teletypewriter = Unix terminal device; pTTY = persistent pseudo-TTY session that survives disconnect).

## Why

- `tmux-persistent-console` is long, descriptive but unmemorable
- `pTTY` reads as a brand, fits the domain `ptty.zentala.io` already planned for GitHub Pages
- Conceptually accurate: project provides persistent pseudo-TTY sessions (tmux is implementation detail)
- Better for v0.2 public release announcement

## Scope

### GitHub
- [ ] Rename repo `zentala/tmux-persistent-console` → `zentala/ptty` (GitHub auto-redirects old URLs)
- [ ] Update repo description and topics
- [ ] Update `origin` remote on local clone

### Code & install paths
- [ ] Default install dir: `~/.tmux-persistent-console` → `~/.ptty` (with migration note in install.sh)
- [ ] systemd unit: `tmux-console.service` → `ptty.service`
- [ ] CLI command name (if any) → `ptty`
- [ ] tmux session name convention if hardcoded
- [ ] `install.sh` / `setup.sh` / `uninstall.sh` — update all paths
- [ ] Backwards-compat symlink `~/.tmux-persistent-console -> ~/.ptty` for existing users (one release cycle)

### Docs
- [ ] README.md — title, install commands, screenshots paths
- [ ] CLAUDE.md (root + subdirs)
- [ ] All references in `00-rules/`, `01-vision/`, `02-planning/`, `03-architecture/`
- [ ] DOCUMENTATION-SUMMARY.md
- [ ] LICENSE header (if it names the project)

### Web / branding
- [ ] GitHub Pages: `ptty.zentala.io` (already in backlog)
- [ ] Logo / banner if produced

## Migration plan for existing users

Add to v0.2 release notes:
```
The project is renamed to pTTY. Old install path ~/.tmux-persistent-console
still works via symlink for v0.2.x. Run `bash ~/.ptty/install.sh --migrate`
to move to the new path.
```

## Out of scope

- Renaming internal tmux session names mid-release (breaks running sessions)
- Forcing existing users to migrate immediately

## Acceptance

- `gh repo view zentala/ptty` returns the repo
- Fresh install on clean VM places files in `~/.ptty/`
- Old `git clone` URL still resolves (GitHub redirect)
- All docs use "pTTY" in prose, `ptty` in code/paths
- v0.2 release announcement uses new name
