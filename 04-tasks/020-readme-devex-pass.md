**Purpose:** Apply the high-leverage DevEx fixes from the README review (2026-05-16). Focus: first-impression conversion, mental-model consistency, scannable Quick Start, no copy ↔ implementation drift.

---

# Task 020: README DevEx pass (review-derived)

**Status:** Pending
**Priority:** High (gates any public launch / Reddit / HN post)
**Type:** Documentation / DevEx
**Estimated effort:** 2–3 hours
**Depends on:** Task 019 (DevEx copy depends on whether we're 10-always-on or 5+5)
**Blocks:** Public launch tasks

---

## Context

Review of `README.md` flagged 15 DevEx issues across three severity bands (full notes in chat history dated 2026-05-16). This task implements the critical and medium-impact fixes. Tech-correctness issues are tracked separately in task 021.

## Acceptance Criteria

### 🔴 Critical fixes

- [ ] **D1**: Solution section paragraph (currently line ~23) no longer says "`Ctrl+F1`–`F12` switches between 5 always-on consoles". Replace with the canonical phrasing introduced by task 019 ("10 always-on consoles; F11 manager; F12 cheatsheet"). Audit the whole file for any other parrots of the wrong phrasing.
- [ ] **D2**: Hero gets a visual. Minimum acceptable: an embedded asciinema GIF (rec the install + first F-key switches). Better: animated SVG / WebM. Placed right under the tagline and badges, above "The Problem". File lives in `docs/assets/`.
- [ ] **D3**: Single canonical mental model used throughout: "10 always-on consoles + Manager + Cheatsheet". After task 019 lands, sweep the whole README to ensure every console reference uses the same number and same framing. Zero whiplash.
- [ ] **D4**: "Perfect For" section moved from line ~165 down to BELOW Key Bindings Reference and AI CLI Workflow Examples. Reader must see what the tool does before being told "perfect for sysadmins".
- [ ] **D5**: Quick Start trimmed. Step 1 (install) stays as-is. Step 2 (SSH alias) split: keep the minimal block visible, wrap the line-by-line explainer in `<details><summary>What each line does</summary>…</details>`. Steps 3 (per-console aliases) and 4 (terminal profiles) moved to a new `## Advanced SSH Setup` section below Quick Start.
- [ ] **D6**: New "Try it locally in 30 seconds" subsection inside Quick Start (or before it), showing `docker run` or `tests/docker/test-local.sh` path. The single biggest "no-commitment" hook the repo has — currently buried in Testing Infrastructure for contributors.

### 🟡 Medium fixes

- [ ] **D7**: Key Bindings Reference table "Purpose" column either (a) renamed to "Suggested use" with a one-line note "these are conventions, not enforced labels", or (b) removed entirely if it's misleading. Setup.sh does not actually label sessions; current "🤖 Console-1 | Claude Code / AI Development" implies it does.
- [ ] **D8**: Table of Contents added right after badges. Use `<details><summary>Table of Contents</summary>…</details>` so it's collapsible. Minimum entries: Problem, Solution, Compare, Quick Start, Key Bindings, Workflow Examples, Troubleshooting, Contributing.
- [ ] **D9**: "🌟 Why This Exists" deduped against "## The Problem". Either remove "Why This Exists" or shrink it to a one-paragraph maintainer note linking to the Problem section.
- [ ] **D10**: "🧪 Testing Infrastructure" Oracle Cloud Terraform block (~40 lines) moved out of README. Leave one sentence: "Want to test against a fresh server? See [`tests/README.md`](tests/README.md)." Move the full content to `tests/README.md` (likely already there; verify and consolidate).
- [ ] **D11**: Troubleshooting section gets one inline TL;DR per common failure. Each subsection: 2 lines inline fix + link to deep docs for the rest. Not "see [docs/troubleshooting.md]" with no inline content.
- [ ] **D12**: New `## Uninstall` section added (3–5 lines). Cover: removing tmux.conf hooks, removing `~/.vps/sessions/`, removing the `connect-console` symlink.

### 🟢 Polish

- [ ] **D13**: Hero paragraph split from one 5-sentence run-on into 3 short paragraphs: (1) problem framing, (2) what survives, (3) the F-key control surface.
- [ ] **D14**: Badge row gets at least one more badge: shellcheck-status (CI), GitHub stars (auto), or PRs-welcome.
- [ ] **D15**: "Ideas for Contributions" list reframed or replaced with link to `gh issue list --label "help wanted"`.

## Implementation Notes

### Asciinema recording (D2)

```bash
asciinema rec docs/assets/install-and-switch.cast
# In recording: curl|bash install, then SSH in, demonstrate Ctrl+F1, F2, F3 switches
# Length: ~30 seconds, max 60
```

Convert to GIF for README embed (asciinema-native player needs JS, GIF works everywhere including HN preview):

```bash
agg docs/assets/install-and-switch.cast docs/assets/install-and-switch.gif
```

### Table of Contents (D8)

```markdown
<details>
<summary>📑 Table of Contents</summary>

- [The Problem](#the-problem)
- [The Solution](#the-solution)
- [How pTTY Compares](#how-ptty-compares-to-adjacent-tools)
- [Quick Start](#-quick-start)
- [Try it locally](#try-it-locally-in-30-seconds)
- [Key Bindings](#-key-bindings-reference)
- [AI CLI Workflow Examples](#-ai-cli-workflow-examples)
- [Troubleshooting](#-troubleshooting)
- [Uninstall](#uninstall)
- [Contributing](#-contributing)

</details>
```

### "Try it locally" (D6) draft

```markdown
### Try it locally in 30 seconds

No SSH, no VPS, no commitment — just Docker:

```bash
git clone https://github.com/zentala/tmux-persistent-console.git
cd tmux-persistent-console
./tests/docker/test-local.sh
```

You'll get a running pTTY in a container. Press `Ctrl+F1`–`F10` to flip between consoles, `Ctrl+F11` for the manager menu, `Ctrl+F12` for the cheatsheet. Exit any time; nothing touches your real system.
```

(Verify `tests/docker/test-local.sh` actually does this; if not, that's a separate task.)

## Out of Scope

- Substantive rewrite of any technical paragraph (that's task 021)
- Translation to other languages
- Adding marketing video / animations beyond the install asciinema
- Renaming "pTTY" anywhere

## Done Definition

1. First-time reader can answer "what does this do, how do I try it" within 60 seconds of opening the README
2. Zero copy ↔ implementation drift (every claim verifiable from `src/`)
3. No section claims a feature the code doesn't deliver (esp. labeled sessions, on-demand consoles)
4. Length: README under 450 lines (currently ~510) after moving Testing Infrastructure out
