**Purpose:** Document the SSH agent forwarding + secrets story for long-running AI coding sessions inside pTTY. Today's README is silent on it, and that's the most common "why doesn't `gh auth` / `git push` work from inside my tmux session?" failure mode.

---

# Task 022: SSH agent forwarding & secrets in AI sessions

**Status:** Pending
**Priority:** Medium (real pain point but not a launch blocker)
**Type:** Documentation
**Estimated effort:** 1–2 hours (incl. testing)
**Depends on:** Task 021 (T14 will leave a stub; this task fills it out)
**Blocks:** Nothing

---

## Context

pTTY is positioned for long Claude Code / Codex / Aider sessions over SSH. Those AI tools routinely shell out to `gh`, `git push`, `kubectl`, `aws`, npm registries with private deps — all of which need credentials.

Two failure modes that hit users repeatedly:

1. **SSH agent never forwarded**. User's `~/.ssh/config` alias for pTTY doesn't have `ForwardAgent yes`, so `git push` from inside a console asks for password or fails outright.
2. **Agent forwarded but lost across detach/reattach**. `SSH_AUTH_SOCK` env var is set when SSH first attaches, but stays pointing at the original socket. When that SSH client dies and a new one attaches to the same tmux session, the env var is stale and tools fail with "no agent" errors.

Both are non-obvious. Neither is mentioned in README. Both have known workarounds.

## Goal

A new short section in README (~30–40 lines) explaining:
- When you need SSH agent forwarding (any AI session that touches gh / git / cloud CLIs)
- How to enable it in the pTTY SSH alias
- How to keep it healthy across reconnects (the `SSH_AUTH_SOCK` symlink trick)
- A "should I forward agent at all?" security note (forwarded agent = remote root can sign as you)

Plus the underlying `~/.tmux.conf` snippet that fixes the stale-socket problem.

## Acceptance Criteria

- [ ] New section in README: `## 🔑 SSH Agent Forwarding (for `gh`, `git push`, cloud CLIs)`. Placed after Quick Start / Advanced SSH Setup.
- [ ] Section explains:
  - Why agent forwarding is useful for AI sessions
  - One-line addition to the alias: `ForwardAgent yes`
  - The stale-socket problem with one-paragraph mechanism
  - The fix: a tmux config snippet that symlinks `SSH_AUTH_SOCK` to a stable path on attach
  - The security trade-off: anyone with root on the remote box can use your forwarded agent while you're attached
- [ ] Working tmux.conf snippet provided. Tested end-to-end on a real server:
  ```tmux
  # Keep SSH_AUTH_SOCK alive across reconnects
  set -g update-environment "SSH_AUTH_SOCK SSH_CONNECTION DISPLAY"
  ```
  Plus the symlink approach if `update-environment` alone isn't enough:
  ```bash
  # In ~/.bashrc or login shell init, BEFORE tmux attach:
  if [ -n "$SSH_AUTH_SOCK" ] && [ "$SSH_AUTH_SOCK" != "$HOME/.ssh/ssh_auth_sock" ]; then
      ln -sf "$SSH_AUTH_SOCK" "$HOME/.ssh/ssh_auth_sock"
  fi
  export SSH_AUTH_SOCK="$HOME/.ssh/ssh_auth_sock"
  ```
- [ ] Manual verification protocol documented:
  ```bash
  # On laptop:
  ssh-add -l                          # confirm key is loaded locally
  ssh tmux.example.com                # connect through pTTY alias
  # Inside tmux:
  ssh-add -l                          # should list the same key
  git ls-remote git@github.com:zentala/tmux-persistent-console.git  # should work
  # Disconnect (close terminal). Reconnect:
  ssh tmux.example.com
  ssh-add -l                          # should STILL list the same key
  git ls-remote git@github.com:zentala/tmux-persistent-console.git  # should still work
  ```
- [ ] Security note explicit: "forwarded agent means anyone with root on the remote machine can sign authentication challenges using your local key while you're attached. Only forward to machines you trust."
- [ ] Cross-reference: `01-vision/VALUE-PROPOSITION.md` gets one sentence under "Target Audience" note acknowledging this is the AI-coding case (so future agents know to keep the section honest).

## Implementation Notes

The `update-environment` line tells tmux to refresh certain env vars from the attaching client. By itself it only updates new windows/panes created after attach — existing shell processes still see the stale value. The symlink trick (write a stable path under `~/.ssh/`, point `SSH_AUTH_SOCK` at it, refresh the symlink on every SSH attach) is the actual fix. Some power users do this in `pam_ssh_agent_auth` or via `keychain` — keep it simple; symlink-in-bashrc covers 95% of cases.

## Testing Requirements

Run the manual verification protocol on:
- Linux (Ubuntu 22.04 box)
- macOS (with built-in SSH agent)
- Windows laptop → Linux server (with Windows OpenSSH client)

Each path should pass.

## Out of Scope

- 1Password SSH agent / Bitwarden / hardware-key (YubiKey) integration — power-user concerns; link out to those tools' docs if asked
- Vault / cloud-secret-manager integration for non-SSH credentials (AWS, GCP) — separate concern
- Implementing any of this as auto-configured behavior in `install.sh` — documenting is the goal; users add the lines themselves

## Done Definition

1. README section answers "why doesn't `gh` work in my pTTY session?" without a reader having to leave the page
2. Verification protocol passes on all three OS combinations above
3. Security warning is unmissable (call-out box, not buried prose)
