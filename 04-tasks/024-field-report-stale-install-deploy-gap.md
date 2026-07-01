# 024 — Field report: systemd unit path + stale-install deploy gap

**Status:** open
**Source:** real-world breakage on a production box (Contabo VPS), 2026-07-01
**Relates to:** [013-fix-path-mismatch-universal.md](013-fix-path-mismatch-universal.md),
[.plan/epic-v0.2-ptty/wave-1-paths.md](../.plan/epic-v0.2-ptty/wave-1-paths.md),
[012-rename-repo-to-ptty.md](012-rename-repo-to-ptty.md),
[020-readme-devex-pass.md](020-readme-devex-pass.md)

## What happened

On a host running an **old install (79 commits behind `main`)**, ptty stopped
working after a reboot. Debugging found the same stale `~/.vps/sessions/src/...`
path problem that wave-1 already fixed in v0.1.3 — but the installed instance
never received that fix. The repo was healthy; the deployed copy was not.

Concretely broken on the box:
- `~/.config/systemd/user/tmux-console.service` → `ExecStart` pointed at
  `%h/.vps/sessions/src/setup.sh` → failed at boot with **status 127** (No such
  file or directory) → **0 sessions created**. Linger was enabled, so the service
  *did* run at boot — it just pointed at a dead path.
- `~/bin/connect-console` → dangling symlink to `.vps/sessions/src/connect.sh`.
- `~/.tmux.conf` → **dangling symlink** to `.vps/sessions/src/tmux.conf` (this is
  why Ctrl+F bindings + status bar didn't load).
- A dead system-level `tmux-sessions.service` unit (enabled symlink, missing file).

## Gap vs wave-1

Wave-1 covered `tmux.conf` + `src/*` scripts. It did **not** cover:
1. the **systemd user unit** `ExecStart` path, nor
2. the possibility that `~/.tmux.conf` itself is a dangling symlink to the old tree, nor
3. **stale installs**: a machine that never re-ran `install.sh` after the fix shipped.

## Proposed improvements (onboarding + UX)

- [ ] **`install.sh`: detect & heal stale installs.** On run, scan for legacy
      `~/.vps/sessions/...` references in the unit, `~/bin/*` symlinks and
      `~/.tmux.conf`; repoint/regenerate them. Make re-running install idempotent
      and self-healing rather than assuming a clean box.
- [ ] **Generate the systemd unit from one source of truth** (the install dir /
      future `PTTY_DIR`), so the unit path can never drift from the scripts.
- [ ] **`ptty doctor` health-check command.** One command that verifies: sessions
      present, unit active, symlinks resolve, `~/.tmux.conf` resolves, bindings
      loaded. First stop for "ptty stopped working" — today the entry point was
      `systemctl --user status tmux-console.service`; bake that check in.
- [ ] **Version/upgrade nudge.** `connect-console` / status bar hints when the
      installed version lags `main` (the root cause here was "fixed upstream,
      never deployed").
- [ ] **README / onboarding:** document the debug entry point and the
      stale-install failure mode in `docs/troubleshooting.md`.

## Notes

Folds naturally into the v0.2 `.ptty` rebrand (task 012 / wave-5): the rename is
the right moment to make install self-healing and add `ptty doctor`, so old
`.tmux-persistent-console` installs migrate cleanly instead of silently breaking.
