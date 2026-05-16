**Purpose:** Fix the technical correctness, security, and SRE-credibility issues identified in the README tech review (2026-05-16). Most are inaccurate claims (tmux version, F-key collisions) or missing safety affordances (install supply-chain, scoped operations).

---

# Task 021: README technical correctness pass (review-derived)

**Status:** Pending
**Priority:** High (incorrect tmux version claim ships users to confusing failures; curl|bash without safety alt blocks corporate adoption)
**Type:** Documentation / Correctness / Security
**Estimated effort:** 2–3 hours
**Depends on:** Task 019 (console count) for consistency; otherwise independent
**Blocks:** Public launch tasks

---

## Context

Tech review of `README.md` flagged 20 issues. The critical ones are correctness bugs (false minimum tmux version, destructive `tmux kill-server` instruction, missing `sudo` warning) and security smells (`curl | bash` with no safety story). Medium issues are precision/clarity. Low issues are nice-to-have polish.

## Acceptance Criteria

### 🔴 Critical fixes

- [ ] **T1 — Safety story for `curl | bash`**. README install section gets a second tab/block titled "Prefer to review before running?" with:
      ```bash
      curl -sSL https://raw.githubusercontent.com/zentala/tmux-persistent-console/main/install.sh -o install.sh
      less install.sh        # eyeball it
      bash install.sh
      ```
      Also add a one-sentence supply-chain disclaimer linking to `SECURITY.md` (stub OK if missing — see also T18).
- [ ] **T2 — Real tmux minimum version**. Audit `src/tmux.conf` and friends for the highest tmux feature in use (likely `display-popup`, format-string source-of-session, `if-shell` patterns). Replace "tmux 2.0+" claim with the verified minimum (probably 3.2). Add a compatibility table:
      | OS | Built-in tmux | Status |
      |----|---------------|--------|
      | Ubuntu 22.04 LTS | 3.2a | ✅ |
      | Debian 11 | 3.1c | ⚠️ Some features degraded |
      | Debian 12 | 3.3a | ✅ |
      | macOS 13+ | 3.3a | ✅ |
      | Alpine 3.18 | 3.3a | ✅ |
      Verify each row before publishing.
- [ ] **T3 — `Ctrl+H` collision warning**. Key Bindings Reference annotates `Ctrl+H` (Shortcuts Popup) with: "*Warning: many terminal emulators send `^H` as backspace. If the popup doesn't trigger, remap to `Ctrl+Shift+H` in `~/.tmux.conf`.*" Optionally change the default binding away from `Ctrl+H` outright.
- [ ] **T4 — `Ctrl+Alt+R` WM collision warning**. Similar annotation: "*Some desktop environments (GNOME screen-record) capture `Ctrl+Alt+R`. If it doesn't work, override in your local `tmux.conf` with a different chord.*"
- [ ] **T5 — Manual install `sudo` clarity**. Line `ln -s ~/.vps/sessions/connect.sh /usr/local/bin/connect-console` updated to either:
      - Prepend `sudo`, or
      - Offer two paths: system-wide (sudo + /usr/local/bin) vs user-local (`mkdir -p ~/.local/bin && ln -s ... ~/.local/bin/connect-console` with a reminder to ensure `~/.local/bin` is on PATH).
- [ ] **T6 — Scoped session reset**. Replace every `tmux kill-server && setup-console-sessions` with the scoped equivalent that kills only pTTY's consoles:
      ```bash
      for s in console-{1..10}; do tmux kill-session -t "$s" 2>/dev/null; done
      setup-console-sessions
      ```
      `kill-server` nukes unrelated tmux sessions on the host and that's a footgun. Hit this in Troubleshooting AND Session Management.

### 🟡 Medium fixes

- [ ] **T7 — SSH config block precision**. Two clarifications inside the explainer:
      1. Note that `tmux new -s NAME` (without `-d`) auto-attaches because it runs under `RequestTTY yes` — useful context for readers who'll copy-paste elsewhere.
      2. Optionally add `TCPKeepAlive yes` to the block, with a one-line comment that some carrier NAT middleboxes drop SSH-level keepalives but respect TCP-level.
- [ ] **T8 — `ServerAliveInterval` rationale precision**. Reword from "keep the TCP connection healthy on flaky WiFi" to: "*After your network drops, the existing SSH connection will time out cleanly in ~90s and exit. Reconnect by running `ssh tmux.example.com` again — it's a fresh connection, but your tmux session is still there on the server.*"
- [ ] **T9 — Nested-tmux gotcha**. New short callout in Quick Start step 2 (or its `<details>` explainer): "*If your remote `~/.bashrc` auto-runs `tmux attach`, the SSH alias's `RemoteCommand` will conflict and you'll see `sessions should be nested with care`. Either gate the auto-attach with `if [ -z "$TMUX" ]`, or remove it.*"
- [ ] **T10 — Function-keys troubleshooting deepened**. Replace "Check terminal emulator settings; verify TERM" with concrete checks:
      ```bash
      # In a fresh tmux session, run:
      tmux info | grep -E 'TERM|client-termname'
      # Expected: tmux-256color or xterm-256color, not 'screen' or 'xterm'
      ```
      Add a fix block showing the `set -g default-terminal "tmux-256color"` + `set -as terminal-overrides ",xterm*:Tc"` lines.
- [ ] **T11 — Window-name reality**. Drop or qualify any claim that consoles are "labeled for Claude Code / Codex / etc." Setup.sh names every window "main". This ties to D7 in task 020 — coordinate.
- [ ] **T13 — Install matrix for `tmux install if missing`**. Either:
      - Spell out which package managers `install.sh` actually supports (verify by reading it), OR
      - Drop the "will install if missing" promise and say "install tmux first (apt/dnf/brew); then run install.sh".
- [ ] **T14 — SSH agent forwarding callout**. New short subsection (or paragraph in Quick Start advanced): "*If your AI session uses `gh`, `git push`, or any tool that needs your SSH key, add `ForwardAgent yes` to the alias block. Inside tmux, ensure `SSH_AUTH_SOCK` is propagated — some shell init scripts unset it on detach/reattach.*"
- [ ] **T15 — `~/.vps/sessions/` path variable**. Anywhere README hardcodes that path, mention it's the default and that users who installed elsewhere should substitute. Optionally introduce `${PTTY_HOME:-~/.vps/sessions}` as a documented env var (but only if install.sh actually respects it — verify or backlog).

### 🟢 Polish

- [ ] **T17 — Project Structure tree comment**. After task 019 lands, change `setup.sh # Creates 5 persistent sessions` (currently "5" but will be wrong on either side of 019) to whatever 019 ends with — likely "10".
- [ ] **T18 — `SECURITY.md` stub**. Create `SECURITY.md` with: how to report vulnerabilities, what's in scope (the install script, safe-exit handling), what's out of scope (downstream user's tmux config). Link from README footer.
- [ ] **T19 — Shellcheck CI badge**. If CI runs shellcheck, add the badge. If it doesn't, that's a separate small task.
- [ ] **T20 — "bash" requirement precision**. Change "Linux/macOS with bash" to "Linux/macOS — install.sh and pTTY scripts run under bash; your interactive shell can be anything (zsh, fish, nushell)."

## Out of Scope

- Hardening `install.sh` itself (separate task — supply-chain track)
- Writing actual cosign signatures or checksums (corp adoption nice-to-have, not v0.2 critical)
- Rewriting any user-facing tutorial-style section (that's task 020 DevEx)

## Done Definition

1. Every command in README runs without surprises on a fresh Ubuntu 22.04 box AND fresh macOS box AND fresh Alpine container (smoke test against the matrix in T2)
2. No claim about minimum tmux version disagrees with reality
3. `curl | bash` has a documented safer alternative on the same screen
4. No instruction silently nukes unrelated tmux sessions on the host
5. Every F-key in the table either works on a default-config terminal, or has a noted collision + override path

## Notes for the implementer

The DevEx task (020) and this task (021) WILL touch the same lines in README. Recommended order:
1. Land task 019 first (changes console count semantics across the file)
2. Then run 020 (structural pass)
3. Then run 021 (correctness pass over the post-020 structure)

Doing them in parallel = merge conflicts and re-verification. Sequential is faster overall.
