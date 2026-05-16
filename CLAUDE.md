# CLAUDE.md - AI Assistant Guidelines

This file provides guidance to Claude Code when working with this codebase.

---

## 🎯 Current Version & Lifecycle Status

**Current Version:** v0.2 (in development)
**Last Completed:** v0.1 (prototype - functional but monolithic)

**Lifecycle Phase:** 00-rules (Workflow Planning & Organization)

**Phase Progress:**
- ✅ **00-rules** - Versioning rules, task archival, folder structure (90% complete)
- 🔄 **01-vision** - Purpose, roadmap, principles (needs review after reorganization)
- 🔄 **02-planning** - SPEC.md, workshops, detailed specs (needs review after reorganization)
- 🔄 **03-architecture** - Technical design, ADRs, lessons (needs review after reorganization)
- ⏳ **04-tasks** - Active tasks for v0.2 (pending - will create after planning review)

**Next Steps:**
1. Complete 00-rules (folder reorganization, VERSIONING.md finalized)
2. Review & organize 01-vision, 02-planning, 03-architecture
3. Define v0.2 scope and create tasks in 04-tasks/
4. Begin implementation

**Instructions by Phase:**
- **00-rules:** Follow [00-rules/VERSIONING.md](00-rules/VERSIONING.md) for version planning
- **01-vision:** Read PURPOSE.md to understand project WHY
- **02-planning:** SPEC.md is SSOT (Single Source of Truth)
- **03-architecture:** Check ADRs before technical decisions
- **04-tasks:** Only work on tasks in `04-tasks/` (current version only)

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
7. **Never conflate "reconnect" with "Ctrl+F1"** — reconnect means SSH back into the server (typically via a `~/.ssh/config` alias with `RemoteCommand tmux attach -t console-1`). `Ctrl+F1`–`F12` is the in-tmux switcher between virtual consoles, like browser tabs, used **after** you're already attached. Copy that mixes the two layers is wrong.
8. **Do not claim systemd / boot persistence as a feature** — pTTY does not try to survive server reboot; that's intentional, out-of-scope, and a fundamentally different product class. The `src/tmux-console.service` file exists for users who want it, but it's not a marketing point.

Full rules, approved taglines, and validation checklist: **[01-vision/VALUE-PROPOSITION.md](01-vision/VALUE-PROPOSITION.md)**

---

## 📐 Specification-Driven Development

**⚠️ CRITICAL: Before making ANY changes, read [02-planning/SPEC.md](02-planning/SPEC.md) - the unified specification.**

All implementation work MUST reference SPEC.md.
All documentation MUST align with SPEC.md.
All conflicts MUST be resolved by updating SPEC.md first.

## 📁 Project Structure & Lifecycle

**Location:** `~/.vps/sessions/` (pTTY root)

### Lifecycle-Based Organization

```
~/.vps/sessions/
├── 00-rules/              # Organizacja pracy (versioning, standards)
├── 01-vision/             # DLACZEGO - Purpose & Direction
├── 02-planning/           # CO - Requirements & Specifications
├── 03-architecture/       # JAK - Solution & Technical Design
├── 04-tasks/              # KIEDY - Active tasks only
├── src/                   # Implementation (code)
├── docs/                  # User documentation
├── tests/                 # Testing infrastructure
├── tools/                 # Development tools
└── archive/               # Historical & completed files
```

**Navigation:**
- Vision (WHY) → `01-vision/README.md`
- Specs (WHAT) → `02-planning/SPEC.md` (SSOT)
- Architecture (HOW) → `03-architecture/ARCHITECTURE.md`
- Tasks (WHEN) → `04-tasks/README.md`

**See:** [TODO-TREE-STRUCTURE.md](TODO-TREE-STRUCTURE.md) for complete structure

---

## 🔢 Versioning Rules ⚠️ CRITICAL

**Version numbers increment by 0.1 ONLY - NEVER skip versions**

### Format: `vMAJOR.MINOR`

**Correct increments:**
- ✅ v0.1 → v0.2 → v0.3 → v0.4 → ... → v0.9 → v1.0
- ✅ v1.0 → v1.1 → v1.2 → v1.3 → ... → v1.9 → v2.0
- ❌ NEVER: v1.2 → v2.0 (must increment: v1.2 → v1.3 → ... → v1.9 → v2.0)
- ❌ NEVER: v0.1 → v1.0 (must increment: v0.1 → v0.2 → ... → v0.9 → v1.0)

**Current version:** v0.2 (in development)
**Last completed:** v0.1 (prototype - functional but monolithic)
**Next milestone:** v1.0 (refactored + production-ready)

**Complete version plan:** [02-planning/VERSIONING.md](02-planning/VERSIONING.md) ⭐

---

## Project Overview

**pTTY (PersistentTTY)** — Persistent terminals for AI coding. An opinionated tmux preset that keeps Claude Code, Codex, Gemini CLI, and Aider sessions alive across SSH drops, WiFi glitches, and laptop sleep. Built on tmux for reliability; differentiated by Ctrl+F1–F12 direct hotkeys, AI-CLI-aware defaults, and safe-exit protection.

**See [01-vision/VALUE-PROPOSITION.md](01-vision/VALUE-PROPOSITION.md) before writing any user-facing content.**

### Project Identity
- **Display name:** pTTY
- **Full name:** PersistentTTY
- **CLI/filesystem:** ptty (lowercase)
- **See:** `docs/naming.md` for complete naming conventions

### ⚠️ CRITICAL: Icon Source of Truth
**ALWAYS use icons from:** `docs/ICONS-NETWORK-SET.md` (lines 130-141)

All implementations MUST follow this canonical mapping:
- Active: 󰢩 (f08a9), Available: 󰱠 (f0c60), Suspended: 󰲝 (f0c9d)
- Manager: 󱫋 (f1acb), Help: 󰲊 (f0c8a)

**See:** `04-tasks/ICON-MAPPING-SOURCE-OF-TRUTH.md` for enforcement rules

### Terminal Configuration
- **5 active consoles by default** (F1-F5) - created on startup
- **5 suspended consoles available** (F6-F10) - created on demand
- **F11** = Manager Menu (interactive TUI with `gum`)
- **F12** = Help Reference (static text display)

**See [SPEC.md](SPEC.md) for:**
- Complete F-key bindings and behavior
- Active vs suspended terminal model
- Manager Menu (F11) specification
- Help Reference (F12) specification
- Status bar design (work in progress)
- Icons and iconography (Nerd Fonts)

## Development Workflow

### 📤 Push & CI/CD Check

**After making changes, ALWAYS check CI/CD builds:**

```bash
# ✅ RECOMMENDED: Push and watch in background (non-blocking)
./tools/push-and-watch.sh &

# ⏸️ Alternative: Push and watch (blocks terminal)
./tools/push-and-watch.sh

# 🔍 Check status anytime
./tools/check-ci.sh

# 👀 Watch in real-time
./tools/watch-ci.sh 10  # Refresh every 10 seconds
```

**Critical:** NEVER push without verifying builds pass!

**Web UI:** https://github.com/zentala/tmux-persistent-console/actions

**Requirements:**
- GitHub CLI installed: `sudo apt install gh`
- Authenticated: `gh auth login`

**See:** [tools/README.md](tools/README.md) for complete documentation

---

## Code Quality Standards

### ⚠️ Critical: Prevent Status Bar Flickering

**Rule:** NEVER use external scripts in tmux status bar with periodic refresh.

**Why:** External script + `status-interval > 0` = visible flicker every N seconds.

**Solution:** Always use native tmux format strings `#{}` with `status-interval 0`.

**Details:** See [techdocs/lesson-01-status-bar-flickering.md](techdocs/lesson-01-status-bar-flickering.md)

**Quick check:**
```tmux
# ❌ BAD - Causes flickering
set -g status-interval 5
set -g status-left '#(script.sh)'

# ✅ GOOD - No flicker
set -g status-interval 0
set -g status-left '#{USER}@#H'
```

### Current Priority: Safe Exit Wrapper Refactoring

**Status**: Working prototype (6.5/10) - needs production hardening
**See**: [TODO.md - Task #0](TODO.md) for detailed improvement plan

**When working on safe-exit.sh**:
1. ✅ Always test changes in actual tmux session
2. ✅ Verify both bash and zsh compatibility
3. ✅ Check all key combinations (Enter, ESC, Y, y, Ctrl+C)
4. ✅ Ensure no race conditions in session restart
5. ✅ Validate temp file security

### Code Review Checklist

Before completing any changes to `src/safe-exit.sh`:

- [ ] Error handling added for all external commands
- [ ] No hardcoded magic numbers (use constants)
- [ ] Trap cleanup guaranteed (use proper error handling)
- [ ] Temp files use `mktemp` with secure permissions
- [ ] Functions are small and single-purpose
- [ ] All user input is sanitized
- [ ] Debug logging available (if `DEBUG_SAFE_EXIT=1`)
- [ ] Tested in both bash and zsh

## Architecture Principles

### Safe Exit Wrapper Design

**Current Issues** (from code review 2025-10-05):
- Mixed responsibilities (UI + logic in one function)
- Lack of error handling
- Security issues with temp files
- No tests

**Target Architecture**:
```bash
safe_exit()
  ├── _is_tmux_session()
  ├── _show_menu()
  ├── _read_user_choice()
  ├── _handle_choice()
  │   ├── _detach_safely()
  │   ├── _restart_session()
  │   └── _stay_in_session()
  └── _cleanup()
```

**Constants** (to be added):
```bash
readonly DETACH_DELAY=0.8
readonly RESTART_DELAY=1
readonly ERROR_DISPLAY_TIME=2
readonly TEMP_DIR="${HOME}/.cache/tmux-console"
```

## Testing Requirements

### Status Bar Testing (CRITICAL)

**⚠️ ALWAYS test status bar changes before committing!**

**Problem:** Tmux color format bugs (commas in conditionals) cause visual glitches.

**Quick Test:**
```bash
# 1. Load config
tmux source-file ~/.vps/sessions/src/tmux.conf

# 2. Check if colors parse correctly (NO "colory" or broken brackets)
tmux show-options -g status-right | head -c 200

# 3. Visual check in CLEAN session
tmux new-session -d -s test-visual
tmux attach -t test-visual
# Type: clear
# Look at bottom: should see "󰢩 F1  F2..." with ONE highlighted

# 4. Run automated test (expects Claude Code NOT running)
bash tests/test-status-bar.sh
```

**Common Bugs:**
- ❌ `#[fg=colour39,bg=colour236]` in conditionals → BREAKS (comma conflicts)
- ✅ `#[fg=colour39]#[bg=colour236]` → WORKS (separate blocks)
- ❌ Testing in Claude Code session → false positives (history pollution)
- ✅ Testing in clean `tmux new-session` → accurate

**Files to check:**
- `src/status-format-v4.tmux` - main status bar definition
- `src/tmux.conf` - loads status-format-v4.tmux
- `tests/test-status-bar.sh` - automated verification

---

### Manual Testing Protocol

Before committing changes to safe-exit.sh:

1. **Test in fresh tmux session**:
   ```bash
   tmux new-session -d -s test-safe-exit
   tmux attach -t test-safe-exit
   source ~/.tmux-persistent-console/safe-exit.sh
   ```

2. **Test all key combinations**:
   - Type `exit` → Press `Enter` → Verify detach message
   - Type `exit` → Press `ESC` → Verify stays in session
   - Type `exit` → Press `Ctrl+C` → Verify stays in session
   - Type `exit` → Press `y` → Verify error message
   - Type `exit` → Press `Y` (SHIFT+Y) → Verify restart
   - Type `exit` → Press `2` → Verify invalid choice message

3. **Test shell compatibility**:
   - Run in bash: `bash` → test all keys
   - Run in zsh: `zsh` → test all keys

4. **Cleanup**:
   ```bash
   tmux kill-session -t test-safe-exit
   ```

### Automated Testing (TODO)

**Priority**: HIGH (see TODO.md #0, Phase 3, task #10)

Create `tests/safe-exit-unit-tests.sh`:
```bash
test_enter_detaches() { ... }
test_esc_stays() { ... }
test_ctrl_c_stays() { ... }
test_shift_y_restarts() { ... }
test_lowercase_y_shows_error() { ... }
test_invalid_key_loops() { ... }
```

## Security Guidelines

### Temp File Handling

**Current (INSECURE)**:
```bash
local restart_script="/tmp/tmux-restart-$session_name.sh"
```

**Required (SECURE)**:
```bash
umask 077  # Only owner can read/write
local restart_script=$(mktemp "${HOME}/.cache/tmux-console/restart-XXXXXX.sh")
trap "rm -f '$restart_script'" EXIT
```

### Input Sanitization

**Always sanitize user-controlled variables**:
```bash
# BAD - potential command injection
echo "Session: $session_name"

# GOOD - sanitized
local safe_name=$(printf '%q' "$session_name")
echo "Session: $safe_name"
```

## Development Workflow

### Making Changes to Safe Exit

1. **Read current implementation**: `src/safe-exit.sh`
2. **Check TODO**: Review TODO.md task #0 for context
3. **Make changes**: Follow architecture principles
4. **Test manually**: Run testing protocol above
5. **Update SAFE-EXIT.md**: Document user-facing changes
6. **Update TODO.md**: Check off completed items
7. **Commit**: Use descriptive commit message

### Commit Message Format

```
refactor(safe-exit): Add error handling for tmux commands

- Check exit codes for all tmux operations
- Show user-friendly error messages
- Gracefully handle missing sessions
- Fixes TODO.md #0, Phase 1, task #5

Related: SAFE-EXIT.md, src/safe-exit.sh
```

## Known Issues & Workarounds

### Race Condition in Session Restart

**Issue**: Background restart script may not complete before user reconnects

**Current workaround**: 1 second sleep (unreliable)

**Proper fix** (TODO #3):
```bash
# Use lock file for synchronization
local lock_file="${HOME}/.cache/tmux-console/restart-${session_name}.lock"
touch "$lock_file"

# In restart script:
sleep 1
tmux new-session -d -s "$session_name" -n "main"
rm -f "$lock_file"

# User can check lock before reconnecting
```

### Trap Cleanup Not Guaranteed

**Issue**: If function exits unexpectedly, trap may stay active

**Current**: Manual cleanup in specific places

**Proper fix** (TODO #2):
```bash
safe_exit() {
    # Set trap at start
    trap '_cleanup; trap - INT' EXIT INT TERM

    # ... function body ...
}

_cleanup() {
    # Always executed before function exits
    trap - INT
}
```

## References

**Primary Documentation:**
- **[SPEC.md](SPEC.md)** - Unified specification (ALWAYS CHECK FIRST!)
- **[README.md](README.md)** - User-facing documentation
- **[docs/naming.md](docs/naming.md)** - Naming conventions (pTTY/ptty)
- **[docs/ICONS.md](docs/ICONS.md)** - Icon reference (Nerd Fonts)
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Technical architecture

**Development Guides:**
- **[TODO.md](TODO.md)** - Current tasks and priorities
- **[SAFE-EXIT.md](SAFE-EXIT.md)** - Safe exit wrapper user guide
- **[tools/README.md](tools/README.md)** - CI/CD monitoring tools

**Technical Docs:**
- **[techdocs/lesson-01-status-bar-flickering.md](techdocs/lesson-01-status-bar-flickering.md)** - Status bar anti-patterns
- **[F12-ISSUES-LOG.md](F12-ISSUES-LOG.md)** - F12 implementation history

## Quick Commands

```bash
# Update safe-exit on server
scp src/safe-exit.sh zentala@164.68.104.13:~/.tmux-persistent-console/

# Test in remote session
ssh zentala@164.68.104.13 -t "tmux attach -t console-1"
source ~/.tmux-persistent-console/safe-exit.sh
exit  # Test the wrapper

# Check for issues
grep -n "TODO\|FIXME\|XXX\|HACK" src/safe-exit.sh
```

## AI Assistant Notes

When asked to improve safe-exit.sh:
1. **Start with Phase 1** tasks (critical security/reliability)
2. **One task at a time** - don't try to fix everything
3. **Always test** before marking complete
4. **Update TODO.md** to track progress
5. **Ask user** before major architectural changes

**Remember**: This is production code protecting user sessions. Bugs can cause data loss. Be careful and thorough.
