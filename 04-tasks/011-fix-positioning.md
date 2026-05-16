**Purpose:** Align project's external positioning with its actual value proposition. Replace overpromised language, introduce pTTY as the public-facing brand, and establish a permanent reference document so future AI agents don't repeat the same positioning mistakes.

---

# Task 011: Fix Positioning & Establish Value Proposition

**Status:** Pending
**Priority:** High (blocks any v0.2 marketing or launch prep)
**Type:** Documentation / Marketing
**Estimated effort:** 2–3 hours
**Depends on:** None (can start immediately)
**Blocks:** Any future Reddit/HN/social launch

---

## Context

The repo currently positions itself as "Tmux Persistent Console" with claims like "Never lose your work" and "Survives anything". This is:

1. **Commercially weak** — "tmux" in the name buries the AI CLI value
2. **Technically false** — when the tmux server dies (reboot, OOM), all sessions are lost; pTTY does NOT protect against this
3. **Brand-incoherent** — `docs/naming.md` already establishes pTTY as the brand, but it's not used anywhere user-facing
4. **Missing from agent context** — `CLAUDE.md` has no value-proposition section, so AI agents repeatedly generate overpromised or off-brand copy

This task fixes all four problems and creates a permanent reference (`VALUE-PROPOSITION.md`) that future agents can consult.

## What pTTY Actually Does (Authoritative)

See `01-vision/VALUE-PROPOSITION.md` after Step 1 of this task. Short version:

- **Protects against** client-side disconnections: SSH drops, WiFi glitches, laptop sleep, network changes, accidental `exit` (~95% of real session-loss events)
- **Does NOT protect against** server-side failures: tmux server crash, server reboot, OOM kill (~5% of events)
- **Mechanism:** tmux server on remote host keeps process memory alive (including AI CLI conversation context) even when SSH client disconnects

This is the contract. Marketing copy must respect it.

## Acceptance Criteria

- [ ] `01-vision/VALUE-PROPOSITION.md` exists with content provided in this task
- [ ] `CLAUDE.md` updated with prominent Value Proposition section near top, linking to canonical doc
- [ ] `README.md` rewritten: new hero, new "How it works" section, new differentiation table, all overpromises removed
- [ ] GitHub repo description updated via `gh repo edit` (typo `setupt` → `setup` fixed, new vendor-neutral tagline)
- [ ] Missing `CONTRIBUTING.md` either created (stub OK) or link removed from README
- [ ] Every occurrence of "Never lose your work", "Survives anything", "Survives server reboots" replaced with specific scenario language
- [ ] Brand name **pTTY** used as primary identifier in all user-facing surfaces (README hero, social, repo description); repo URL stays `tmux-persistent-console` (do not rename — would break all existing links)
- [ ] No vendor names ("Claude", "Codex", "Gemini") used as product-name components anywhere — only in descriptive context
- [ ] All changes pushed to a branch (e.g., `task/011-positioning`) and CI passes before merge

## Implementation Steps

### Step 1 — Create `01-vision/VALUE-PROPOSITION.md`

Copy the content from the companion file `VALUE-PROPOSITION.md` into `01-vision/VALUE-PROPOSITION.md`. This becomes the canonical source of truth for what pTTY is and how to talk about it.

### Step 2 — Update `CLAUDE.md`

Add the following section **immediately after the "Current Version & Lifecycle Status" section** and before "Specification-Driven Development":

```markdown
---

## 🎯 Value Proposition — READ FIRST For Any User-Facing Work

**⚠️ CRITICAL: Before writing ANY user-facing content (README, social posts, taglines, marketing copy, GitHub description, blog posts), read [01-vision/VALUE-PROPOSITION.md](01-vision/VALUE-PROPOSITION.md) in full and validate against its checklist.**

### What pTTY actually is (one sentence)

pTTY is an opinionated tmux preset that keeps AI coding sessions alive across SSH drops, WiFi glitches, and laptop sleep — so Claude Code, Codex, Gemini CLI, and Aider context survives every disconnection **except a full server crash**.

### What pTTY is NOT

- NOT a tmux replacement (it's a preset on top of tmux)
- NOT a session manager like tmuxinator (different use case)
- NOT a recovery tool like tmux-resurrect (different mechanism, different guarantees)
- NOT a Claude-only tool (vendor-neutral; works with any AI CLI)

### Hard rules for AI agents

When generating any user-facing content for pTTY:

1. **Brand name is "pTTY"** — never "tmux-persistent-console" in marketing (repo URL only)
2. **Never claim** "never lose your session", "indestructible", "survives anything" — all overpromises (server crashes still kill sessions)
3. **Always specify scenarios** pTTY protects against: SSH drops, WiFi, laptop sleep, network change, accidental `exit`
4. **Never put vendor names in product name** — "Claude", "Codex", "Gemini" appear only in descriptions ("works with...")
5. **Differentiate honestly** from tmuxinator (project setup), tmux-resurrect (recovery, loses AI context), zellij (alternative substrate)
6. **Acknowledge the mechanism** when audience is technical: tmux server keeps process alive in memory; that's how the AI conversation context survives

Full rules, approved taglines, and validation checklist: **[01-vision/VALUE-PROPOSITION.md](01-vision/VALUE-PROPOSITION.md)**

---
```

Also update the existing "Project Overview" section. Replace its current opening paragraph with:

```markdown
## Project Overview

**pTTY (PersistentTTY)** — Persistent terminals for AI coding. An opinionated tmux preset that keeps Claude Code, Codex, Gemini CLI, and Aider sessions alive across SSH drops, WiFi glitches, and laptop sleep. Built on tmux for reliability; differentiated by Ctrl+F1–F12 direct hotkeys, AI-CLI-aware defaults, and safe-exit protection.

**See [01-vision/VALUE-PROPOSITION.md](01-vision/VALUE-PROPOSITION.md) before writing any user-facing content.**
```

(Keep the rest of "Project Overview" — Identity, Icons, Terminal Configuration — as is.)

### Step 3 — Rewrite `README.md`

Replace the current hero (everything from `# 🖥️ Tmux Persistent Console` through the end of "✅ The Solution" section) with:

```markdown
# 🖥️ pTTY — Persistent terminals for AI coding

> Your Claude Code, Codex, Gemini CLI, and Aider sessions survive SSH drops, bad WiFi, and laptop sleep. Reconnect with `Ctrl+F1` and pick up exactly where you left off — same conversation context, same scrollback, same running processes.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Built on tmux](https://img.shields.io/badge/Built%20on-tmux-green.svg)](https://github.com/tmux/tmux)
[![Shell: Bash](https://img.shields.io/badge/Shell-Bash-blue.svg)](https://www.gnu.org/software/bash/)

## The Problem

You're SSH'd into a remote server running a long Claude Code session. Your WiFi flakes for 10 seconds. SSH disconnects. You reconnect — and your AI conversation context, your scrollback, your background processes are **gone**. You rebuild context. It takes 20 minutes. Then it happens again.

This is the daily reality of remote AI-assisted development:

- **SSH drops** when WiFi changes or VPN flaps
- **Laptop sleep** kills the connection mid-session
- **Network switches** (home → mobile → cafe) require full reconnection
- **Accidental `exit`** in the wrong terminal destroys the session
- All your Claude Code / Codex / Aider context lives in memory — and it dies with the connection

## The Solution

pTTY keeps the **process alive on the server** while you reconnect. tmux runs as a server process; your AI CLI runs as its child; both keep going even when SSH dies. Reconnect, hit `Ctrl+F1`, and you're back exactly where you were — same conversation, same scrollback, same running processes.

### What pTTY protects you from

- ✅ SSH connection drops (network instability, ISP issues, VPN flap)
- ✅ WiFi glitches (coffee shop, train, hotel)
- ✅ Laptop sleep (lid close, low battery, OS suspend)
- ✅ Network changes (home WiFi → mobile hotspot → office)
- ✅ Accidental `exit` in the wrong terminal (safe-exit confirmation)

### What pTTY does NOT protect you from

- ❌ Server reboot (tmux server dies → sessions lost — this is rare; ~5% of real-world session loss)
- ❌ tmux server crash (OOM kill, manual `kill-server`)

If you need crash-survivable AI sessions, that's a different product (state replication + cloud sync). pTTY is laser-focused on the 95% case: client-side disconnections.
```

Then add a new section after "✨ Features" called "How pTTY Compares":

```markdown
## How pTTY Compares to Adjacent Tools

| Tool | What it does | When to use it instead of pTTY |
|------|--------------|--------------------------------|
| **Raw tmux** | Terminal multiplexer | When you want full control and don't mind configuring everything yourself |
| **tmuxinator** | Project setup via YAML | When you need different layouts per project (complementary to pTTY, not competitive) |
| **tmux-resurrect** | Save/restore tmux state after server death | When server reboots are your main concern and you can tolerate losing AI conversation context (resurrect restarts processes from scratch) |
| **zellij** | Modern tmux alternative in Rust | When you want a different multiplexer and don't need AI-CLI-optimized defaults |
| **mosh** | SSH replacement with roaming | Complementary — solves the connection layer; pTTY solves the session layer. Use both. |

**pTTY's unique combination** (no other tool has all five):

1. **Zero configuration** — 5 sessions ready after one install command
2. **Ctrl+F1–F12 direct hotkeys** — no prefix-key gymnastics; works like browser tabs
3. **AI CLI workflow defaults** — sessions pre-labeled for AI development
4. **Safe-exit protection** — prevents accidental session destruction
5. **Systemd auto-start** — sessions reappear after reboot (empty, ready to use)
```

Search and replace across the entire README:

- `"Never lose your work when SSH crashes again!"` → `"Your AI coding session survives every SSH drop, WiFi glitch, and laptop sleep."`
- `"7 persistent tmux sessions that survive anything"` → `"5 always-on terminal sessions that survive client-side disconnections"`
- `"Survives server reboots (with proper setup)"` → remove this line entirely (overpromise — only systemd auto-start brings empty sessions back)
- `"Auto-recovery from network issues"` → `"Reconnect over any new network and pick up where you left off"`
- Every occurrence of `"Tmux Persistent Console"` (as product name) → `"pTTY"` (keep "tmux-persistent-console" only when referring to the GitHub repo URL or filesystem paths)
- `"Made with ❤️ for remote workers, sysadmins, and AI CLI enthusiasts."` → `"Made with ❤️ for developers who code with AI on remote servers."`

### Step 4 — Update GitHub repo description

Run:

```bash
gh repo edit zentala/tmux-persistent-console \
  --description "pTTY — persistent terminals for AI coding. Keep Claude Code, Codex, Gemini CLI, and Aider sessions alive across SSH drops, WiFi glitches, and laptop sleep. Built on tmux with Ctrl+F1–F12 hotkeys for instant switching."
```

This fixes the `setupt` typo and replaces the overpromise-heavy current description.

Also update repo topics to add:

```bash
gh repo edit zentala/tmux-persistent-console \
  --add-topic claude-code \
  --add-topic codex \
  --add-topic aider \
  --add-topic ai-coding \
  --add-topic developer-experience \
  --add-topic devex
```

### Step 5 — Handle missing `CONTRIBUTING.md`

README links to `CONTRIBUTING.md` but it doesn't exist. Either:

**Option A (recommended):** Create a stub `CONTRIBUTING.md`:

```markdown
**Purpose:** How to contribute to pTTY.

# Contributing to pTTY

Thanks for considering a contribution! pTTY is a small project; contributions are very welcome.

## Before You Start

1. Read [01-vision/PURPOSE.md](01-vision/PURPOSE.md) to understand what pTTY is for
2. Read [01-vision/VALUE-PROPOSITION.md](01-vision/VALUE-PROPOSITION.md) to understand the scope (what's in, what's out)
3. Check [04-tasks/TODO.md](04-tasks/TODO.md) for what's currently being worked on
4. For larger changes, open an issue first to discuss

## How to Contribute

- **Bug reports:** Open an issue with reproduction steps, OS, tmux version, and terminal emulator
- **Feature requests:** Open an issue; check the value proposition first (some features intentionally out of scope)
- **Pull requests:**
  - Branch from `main`
  - Follow [00-rules/CODE-STANDARDS.md](00-rules/CODE-STANDARDS.md)
  - Use conventional commits (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`)
  - Run manual tests per [00-rules/testing-manual.md](00-rules/testing-manual.md) before pushing
  - Wait for CI green before requesting review

## Working with AI Tools

This repo is friendly to AI-assisted contributions. We use [CLAUDE.md](CLAUDE.md) to guide Claude Code and other agents. If you use an AI assistant, please:

- Have it read `CLAUDE.md` and `01-vision/VALUE-PROPOSITION.md` before generating user-facing content
- Verify any positioning/marketing copy against the Value Proposition checklist

## License

By contributing, you agree your contributions will be licensed under the MIT License.
```

**Option B:** Remove the link from README until you have time to write it.

Prefer Option A — even a stub is better than a broken link.

### Step 6 — Verify and commit

1. Run `markdown-link-check README.md` (or visually check) to verify no broken links remain
2. View README rendered on GitHub (push to a branch first)
3. Verify no occurrence of "never lose" / "indestructible" / "survives anything" remains: `grep -rn -i "never lose\|indestructible\|survives anything\|survives server" README.md`
4. Commit on branch `task/011-positioning` with conventional commit:

```
docs(positioning): align messaging with honest value proposition

- Add 01-vision/VALUE-PROPOSITION.md as canonical brand & messaging source
- Add Value Proposition section to CLAUDE.md for AI agent guidance
- Rewrite README hero with pTTY brand + honest scope
- Add competitor comparison table
- Remove overpromises ("never lose", "survives anything")
- Update GitHub repo description and topics
- Add CONTRIBUTING.md stub

Closes: 04-tasks/011-fix-positioning.md
Refs: 01-vision/VALUE-PROPOSITION.md
```

5. Push and watch CI:

```bash
./tools/push-and-watch.sh &
```

6. Open PR for self-review before merging.

## Out of Scope (Do NOT do in this task)

- Renaming the GitHub repo (would break all external links and stargazers — leave URL alone, only change branding)
- Logo / visual identity work (separate task)
- Demo GIF / asciinema recording (separate task — important but distinct)
- Domain registration (`ptty.dev` / `ptty.sh` — separate task)
- Reaching out to influencers / posting to Reddit / HN (launch task, comes after this)
- Translating README to other languages (premature)

## Done Definition

This task is done when:

1. A new contributor opens the repo and within 30 seconds knows: (a) what pTTY does, (b) what it does NOT do, (c) how it differs from tmux-resurrect
2. An AI agent reading `CLAUDE.md` can answer "what's the value proposition?" without hallucinating overpromises
3. No string match for "never lose", "indestructible", "survives anything", "survives server reboot" anywhere in user-facing docs
4. `gh repo view` shows the new description without typos
5. All CI checks pass on the merge commit
