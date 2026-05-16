**Purpose:** Single source of truth for what pTTY is, what value it provides, and how to talk about it. All marketing copy, README content, social posts, taglines, and positioning decisions MUST align with this document. AI agents working on pTTY MUST read this file before generating any user-facing content.

---

# pTTY Value Proposition

## TL;DR

**pTTY is an opinionated tmux preset that keeps your AI coding sessions alive across SSH drops, WiFi glitches, and laptop sleep — so your Claude Code, Codex, Gemini CLI, or Aider context survives every disconnection except a full server crash.**

That sentence is the contract. Don't promise more.

---

## What pTTY Actually Is

pTTY (PersistentTTY) is a thin, opinionated layer on top of tmux. It is **not** a tmux replacement, **not** a session manager in the tmuxinator sense, and **not** a state-recovery tool like tmux-resurrect.

It is a preset + UX layer that makes tmux frictionless for one specific job: **long-running AI-assisted coding sessions on remote servers**.

## The Core Value (Honest Version)

pTTY protects your AI coding session from these real, common scenarios:

- **SSH drops** — network instability, ISP issues, VPN flap, mobile tethering
- **WiFi glitches** — coffee shop, train, hotel, conference center
- **Laptop sleep** — lid close, low battery, OS suspend
- **Network changes** — home → mobile hotspot → office WiFi
- **Accidental exit** — `exit` typed in the wrong terminal (safe-exit protection)

pTTY does **NOT** protect against:

- **Server reboot** — tmux server dies, all sessions lost
- **tmux server crash** — OOM kill, manual `tmux kill-server`
- **The AI tool's own state loss** — Claude Code's conversation storage is separate from tmux

**Why this matters:** the protected scenarios represent ~95% of real session-loss events for remote developers. Server crashes are rare; SSH drops happen daily. pTTY targets the high-frequency pain, not the rare catastrophe.

## The Mechanism (Why It Works)

tmux runs as a **server process on the remote machine**. The SSH client connects to that server. Sessions live in the server's memory along with all child processes.

When SSH dies:
- The tmux server keeps running
- Child processes (including Claude Code, Codex, etc.) keep running
- Scrollback stays in memory
- The AI CLI's in-memory conversation context stays

The user reconnects via SSH + `tmux attach` (or pTTY's F-key shortcuts) and lands exactly where they left off.

This is **fundamentally different** from save/restore tools like tmux-resurrect. Resurrect restarts processes from saved metadata — meaning the AI conversation context (which lives in process memory) is gone, replaced by a fresh process. pTTY keeps the original process alive, so the context stays.

**This distinction is the core technical argument for pTTY in any conversation with sophisticated developers.**

## Differentiation From Adjacent Tools

| Tool | What it does | Why pTTY is different |
|------|--------------|------------------------|
| **Raw tmux** | Terminal multiplexer | No opinionated UX, manual config, prefix-key navigation |
| **tmuxinator** | Project setup via YAML | Solves "how to bootstrap a project", not "how to keep AI session alive"; per-project config required |
| **tmux-resurrect** | Save/restore sessions across server death | Restarts processes → loses in-memory AI context; doesn't help with SSH drops at all |
| **zellij** | Modern tmux alternative in Rust | Substrate not preset; session persistence historically weaker than tmux; no AI CLI focus |
| **mosh** | SSH replacement with roaming | Helps with the connection layer but doesn't multiplex sessions or label them for AI workflows; complementary, not competitive |

pTTY's unique combination — none of the above have all five:

1. **Zero configuration** — 5 sessions ready after one install command
2. **Ctrl+F1–F12 direct hotkeys** — no prefix-key gymnastics, works like browser tabs
3. **AI CLI workflow defaults** — sessions pre-labeled for AI use cases
4. **Safe-exit protection** — prevents accidental session destruction via `exit`
5. **Systemd auto-start** — sessions reappear after reboot (empty, but ready)

## Target Audience (Priority Order)

1. **AI CLI users on remote servers** — Claude Code, Codex, Gemini CLI, Aider, Copilot CLI users who SSH into VPS/cloud machines. This is the biggest, fastest-growing, most underserved segment. **All marketing leads with them.**
2. **Remote workers with flaky connectivity** — travelers, cafe workers, mobile devs
3. **Sysadmins running long operations** — updates, deployments, monitoring
4. **Power tmux users wanting better defaults** — secondary audience, not primary

When in doubt about audience, optimize for audience #1.

## Naming & Branding Rules (Strict)

### Product naming

| Context | Use |
|---------|-----|
| Display name | **pTTY** |
| Full / formal name | **PersistentTTY** |
| CLI command, filesystem paths | **ptty** (lowercase) |
| GitHub repo URL | `tmux-persistent-console` (historical, do not change — would break all links) |

### Vendor names — DO NOT use in product name, title, or branding

- "Claude" / "Claude Code" (Anthropic trademark)
- "Codex" (OpenAI trademark)
- "Gemini" (Google trademark)
- "Copilot" / "GitHub Copilot" (Microsoft/GitHub trademark)
- Any other vendor name

This protects against trademark cease-and-desist letters AND prevents the product from looking single-vendor when new AI CLIs inevitably emerge.

### Vendor names — ALLOWED in

- Repo description ("Works with Claude Code, Codex...")
- README body text
- Marketing copy ("Built for Claude Code users")
- Feature lists
- Documentation
- Social posts

The rule: **vendor names describe what pTTY works with, never what pTTY is**.

## Marketing Copy Rules (Strict)

### NEVER write

- ❌ "Never lose your AI session" — overpromise, server crashes still lose sessions
- ❌ "Indestructible sessions" — false
- ❌ "Survives anything" — false (current README says this, must change)
- ❌ "Built only for Claude Code" — vendor lock-in, limits TAM
- ❌ "Your work is safe forever" — overpromise

### ALWAYS write

- ✅ Specific scenarios: "Survive SSH drops, bad WiFi, and laptop sleep"
- ✅ Honest scope: "Your session stays alive on the server while you reconnect"
- ✅ Vendor-neutral framing: "Works with Claude Code, Codex, Gemini CLI, Aider, and any AI CLI"
- ✅ Mechanism-aware: "Keeps the process alive, not just the state"
- ✅ Concrete actions: "Reconnect with `Ctrl+F1`"

## Approved Tagline Variants

### Primary (README hero)

> **Persistent terminals for AI coding.**
>
> Your Claude Code, Codex, Gemini CLI, and Aider sessions survive SSH drops, bad WiFi, and laptop sleep. Reconnect with `Ctrl+F1` and pick up exactly where you left off — same conversation context, same scrollback, same running processes.

### GitHub repo description (~350 char limit)

> pTTY — persistent terminals for AI coding. Keep Claude Code, Codex, Gemini CLI, and Aider sessions alive across SSH drops, WiFi glitches, and laptop sleep. Built on tmux with Ctrl+F1–F12 hotkeys for instant switching between 5 always-on consoles.

### Social one-liner

> pTTY: 5 persistent terminals for your AI CLI work. SSH drops? Reconnect with Ctrl+F1 — your session is still running on the server.

### Hacker News / Reddit / developer audience

> Opinionated tmux preset for keeping AI coding sessions alive on remote servers when your SSH connection dies. Built on tmux, optimized for Claude Code, Codex, Gemini CLI, and Aider. Function-key hotkeys instead of prefix-key gymnastics.

## Positioning Temptations to Resist

The temptation to drift positioning will appear in three forms. Resist each:

**1. "Let's broaden — pTTY for all developers, not just AI users"**
→ No. Generic "better tmux" is a crowded, mature space (zellij wins on novelty, tmux wins on stability). The AI CLI niche is uncontested and the target market is exploding. **Niche down, don't broaden.**

**2. "Let's pivot — safe-exit is the killer feature, lead with that"**
→ No. Safe-exit is a feature inside the product, not the product itself. The product is "persistence + AI CLI workflow"; safe-exit is part of the moat. Leading with safe-exit confuses the buyer about what they're getting.

**3. "Let's promise cloud state sync so it survives server crashes too"**
→ Maybe in v2.0+, but be honest: state replication, conflict resolution, and cloud infrastructure are a fundamentally different product. Do not include this in v0.x or v1.0 marketing under any framing.

## Checklist for AI Agents Writing User-Facing Content

Before committing any README change, social post, tagline, or marketing copy, validate against:

- [ ] Does it use "pTTY" as the brand name (not "tmux-persistent-console")?
- [ ] Does it claim "never lose" / "indestructible" / "survives anything"? → If yes, rewrite, too strong
- [ ] Does it mention specific protection scenarios (SSH/WiFi/sleep)? → Required
- [ ] Does it list AI CLI vendors only in descriptions, never in product name? → Required
- [ ] Does it overpromise server-crash protection? → If yes, rewrite
- [ ] Does it acknowledge tmux as the underlying substrate? → Required for technical audiences
- [ ] If differentiating from competitors, is the differentiation accurate? (see table above)
- [ ] Does it lead with audience #1 (AI CLI users)?
- [ ] Are vendor names spelled correctly? (Claude Code, Codex, Gemini CLI, Aider, GitHub Copilot CLI)

If any answer is wrong, rewrite before shipping.

---

**Last reviewed:** 2026-05-16
**Owner:** Project maintainer
**Status:** Authoritative — overrides any conflicting language in older docs
