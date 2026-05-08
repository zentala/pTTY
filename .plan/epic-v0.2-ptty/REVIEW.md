# Review log — Epic pTTY v0.2

**Epic:** [README.md](README.md) · **Architecture:** [ARCHITECTURE.md](ARCHITECTURE.md) · **PRD:** [PRD.md](PRD.md)

---

## CEO Review

**Reviewer:** Claude (Opus 4.7), self-review framed as product / strategy
**Date:** 2026-05-08
**Verdict:** 🟢 **GO with conditions**

### Why this matters

pTTY's pitch is "SSH + reboot? Twoja sesja żyje". F11 i F12 to **jedyne** interaktywne UI projektu. Dziś F11 jest dwustopniowe, F12 jest statycznym tekstem, **oba są zepsute** (ścieżki). Pierwsze wrażenie z release'u v0.2 zależy od tych dwóch ekranów. Reszta projektu to plumbing.

### Strategic assessment

| Dimension | Finding |
|-----------|---------|
| Time-to-"wow" | F11 popup z metrykami daje natychmiastowe poczucie kontroli. Demo-friendly. Tweet-friendly. |
| Differentiation | vs. gołe tmux: branding (pTTY), uptime/CPU per-console, slot-aware. vs. Zellij: lżejsze, bash-only, instaluje się w 30s. |
| README story | Animowany GIF F11 robi robotę. F12 which-key — drugi GIF. Bez tego release ma trzy strony tekstu i nic do pokazania. |
| Risk | Single-key UX odkrywany na bieżąco; trzeba dobry on-boarding (pierwsze otwarcie F11 → tooltip "press ? for help"). |

### Conditions for release

1. **Wave 1 ship-blocker** — bez tego v0.2 nie ma sensu, bo nikt nie zobaczy F11/F12.
2. **Asset budget** — 2 GIF-y do README (F11 demo, F12 demo) przed merge'em do master. Use `vhs` for reproducibility.
3. **Plugin decision now** — sessionx adopt vs. own zostało rozstrzygnięte (Q2: hybryda). Nie zwlekać dalej.
4. **Naming** — rename (Wave 5) idzie razem z v0.2. F11/F12 muszą pokazywać "pTTY" w tytule popup. Spójność marki w pierwszym kontakcie.

### What I'm cutting (for now)

- Multi-select w managerze — v0.3.
- Drag-to-reorder F-slots — v0.3.
- Go rewrite — v1.0 (Task 017), nie blokuje.
- Onboarding tutorial mode — v1.0.

### Watch-outs for next epic

- If v0.2 launch lands well, **immediately** set up issue templates for "I tried to do X" so we capture v0.3 priorities from real users, not guesses.
- Consider a "pTTY for selfhosters" angle in marketing — Proxmox / homelab community is a high-affinity audience and you already live there.

---

## Engineering Review

**Reviewer:** Claude (Opus 4.7), self-review framed as senior eng
**Date:** 2026-05-08
**Verdict:** 🟡 **CONDITIONAL GO**

### Architecture call-outs

| Topic | Finding | Action |
|-------|---------|--------|
| Path universality | `set-environment -g PTTY_DIR` + sed-template w `install.sh` to standard. **OK.** | Egzekwować `grep -r "vps/sessions"` w pre-commit / CI — żaden hardcode się nie wśliźnie. |
| Popup compat | tmux ≥ 3.2 wymagane (Q4). Repo dziś ma fallback (`display-popup -h 1 'echo test'`) do split-window — **usunąć** zgodnie z Q4. Kod nie ma być "może działa". | Jednoznaczna pre-flight check w `install.sh`, przerywa instalację z linkiem do upgrade'u. |
| Fzf vs. gum vs. own | Bash + fzf `--bind` obsłuży 100% F11. **Nie wprowadzać Go w v0.2** (Task 017 = v1.0). | OK; Wave 3 zostaje na bash+fzf. |
| Stale parsing | Dziś `awk '{print $3}'` z display rows = bomba. | Wave 2-c `lib/format.sh`: każdy wiersz to `$F_KEY\t$STATUS\t$SESSION\t$JSON`, fzf renderuje przez format spec, akcje czytają tab-separated → solidnie. |
| Help auto-gen | Annotation w `tmux.conf`: `# @group:nav @desc:Jump to console 1`. | Parser w bash, ~30 linii. Jeden punkt prawdy = klucz w conf, nie duplikowany w docstr. Wave 4-a. |
| Tests | bats (już zaplanowane). | Smoke: `tmux send-keys C-F11`, `tmux capture-pane`, assert nagłówek. Nie testować pikseli, testować tekst. Wave 5. |

### Risks & mitigations

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| `PTTY_DIR` template fails na egzotycznych shellach | Low | Medium | sed jest POSIX, testowane na bash/zsh/dash w CI |
| `tmux-which-key` nie pasuje do naszej annotation style | Medium | Medium | Wave 4-a zaczyna się 1-day prototype'em; fallback to `src/ui/help.sh` własny |
| Single-key destructive `K` | Low | High | confirm dialog default Cancel, kursor na "No"; ADR-007 dokumentuje UX |
| fzf < 0.30 brak `--bind reload` | Medium | Medium | install.sh sprawdza wersję, podpowiada upgrade |
| Race podczas restart | Low | Medium | lock-file w `~/.cache/ptty/locks/`, trap EXIT cleanup |
| README GIF-y nie powstaną | Medium | High | Wave 5 explicite alokuje czas; `vhs` (charm.sh) dla reprodukowalności |
| tmux 4.0 zmienia popup semantykę | Very low | Medium | version-pin minimum (≥3.2 ≤3.x); revisit przy 4.0 release |
| Existing users łamią się na usunięciu `~/.vps/sessions/` | Low | Medium | symlink shim na 1 release; CHANGELOG migration section |

### Sequencing

```
Day 1-2  Wave 1 (paths)             — BLOCKER
Day 3-4  Wave 2 (state, actions, lib) — parallel a/b/c
Day 5-7  Wave 3 (F11 popup)
Day 8    Wave 4 (F12 + plugins)      — parallel a/b
Day 9    Wave 5 (rebrand + release)
```

Razem ~9 dni roboczych. Bufor: 2 dni na nieprzewidziane (plugin nie pasuje, GIF nie wychodzi).

### Code quality requirements

Already documented in `03-architecture/CODE-STANDARDS.md`. Highlights for this epic:

- Functions in `src/lib/*.sh` and `src/core/*.sh` are **pure** (no `tmux` side-effects, only reads).
- Mutating actions in `src/actions/*.sh` always atomic or no-op.
- Every script starts with `set -euo pipefail`.
- `shellcheck` clean (CI gate).
- No global state except cached values via tmux user options.

---

## Design Review

**Reviewer:** Claude (Opus 4.7), self-review framed as senior product designer (terminal UI specialty)
**Date:** 2026-05-08
**Verdict:** 🟡 **CONDITIONAL GO**

### Scope

Reviewed against `02-planning/mockups/f11-f12-redesign.html` and Wave 3 / Wave 4-A specs.

### Strong points

| Aspect | Verdict | Notes |
|--------|---------|-------|
| Information architecture | ✅ Excellent | F-key as primary key (left column) maps to user mental model — they think "F3 is my dev console", not "console-3 is my dev console" |
| Single-screen, single-key | ✅ Excellent | lazygit/k9s/btop convention; nothing surprises a TUI user |
| Status semantics | ✅ Strong | 5 states (live/idle/sleep/dead/slot) cover the real lifecycle without overlap |
| Slot-aware empty rows | ✅ Excellent | Showing `(empty — press n)` is teaching the affordance in-place; saves a help round-trip |
| Visual hierarchy in mockup | ✅ Good | Selected row uses background + left border (not just color) — accessible to color-blind users |
| Confirm dialog default = Cancel | ✅ Mandatory | Standard for destructive actions; matches `rm -i` and lazygit conventions |

### Issues found

#### D1 — `K` for kill conflicts with vi `k` muscle memory (LOW, accept)
**Finding:** vi users press `k` to move up. Shift-K = kill is a real cognitive switch on the destructive path.
**Severity:** Low — confirm dialog catches mistakes; lazygit uses the same convention.
**Action:** Accept. Document in F12 with explicit hint: "K (uppercase) — kill. Cancel by default in confirm."

#### D2 — Color/icon legend buried (MEDIUM)
**Finding:** Status icons `● ○ ◐ ✖ ·` are clear in mockup with legend below. In the actual popup, no legend is rendered. New users see `● live` but `· slot` is opaque.
**Severity:** Medium — first-run friction.
**Action:** Wave 3 spec must add icon-name pairs in the column header, NOT a separate legend. Header reads: `Status (●live ○idle ◐sleep ✖dead ·slot)`. One-line, always visible. **Add to wave-3 acceptance.**

#### D3 — Preview pane shows random content for `dead` state (MEDIUM)
**Finding:** `tmux capture-pane` on a dead session returns whatever was last there — could be a stack trace mid-render. Looks broken.
**Severity:** Medium — confusing UX in error state.
**Action:** Wave 3 manager.sh: when state == `dead`, preview shows a fixed message: `"Session in error state. Press 'r' to restart, 'K' to remove."`. **Add to wave-3 acceptance.**

#### D4 — 80-column degradation not specified (HIGH)
**Finding:** Wave 3 spec says "drop CPU/Mem on `tput cols < 100`" but doesn't specify which columns degrade in what order. Risk: arbitrary cut-off looks broken.
**Severity:** High — Task 011 explicitly flagged 80-col as known issue.
**Action:** Define column priority for degradation:
```
≥120 cols: F-key | Status | Console | Uptime | Last cmd | CPU | Mem
100–119:   F-key | Status | Console | Uptime | Last cmd
80–99:     F-key | Status | Console | Last cmd
<80:       F-key | Status | Console
```
**Add explicit table to wave-3 spec.**

#### D5 — F12 toggle behavior unclear (LOW)
**Finding:** Wave 4-A says "F12 toggles" but `display-popup` doesn't natively support toggle. While popup is open, terminal swallows F12.
**Severity:** Low — most users press `q` or `Esc` anyway.
**Action:** Drop "toggle" claim from acceptance. Document: "F12 opens; q/Esc closes". If user re-presses F12 while open, it's a no-op (no harm, no help). **Update wave-4-a acceptance.**

#### D6 — No empty-state for "all 10 slots used" (LOW)
**Finding:** When all slots are taken, pressing `n` exits 5 silently (per Wave 2-B contract). User sees nothing happen.
**Severity:** Low — uncommon path.
**Action:** Manager.sh catches exit 5 from new.sh, shows toast "All 10 F-slots in use. Free one with K to create new." **Add to wave-3 spec.**

#### D7 — Active session marker missing (MEDIUM)
**Finding:** Mockup shows `▸` cursor on selected row but no visual mark for *currently attached* session. Two pieces of state (selection vs. attachment) need different signals.
**Severity:** Medium — confuses "I selected this" vs. "I'm sitting in this".
**Action:** Add a small marker in F-key column for currently-attached session:
```
F1   ●  live  console-1  …
F3 ★ ●  live  console-3  …    ← currently attached (filled star)
```
**Add to wave-3 spec.**

#### D8 — No keyboard discoverability without F12 (LOW)
**Finding:** First-run user opens F11 popup, doesn't know about `?` for help.
**Severity:** Low — header line lists keys.
**Action:** Header in popup explicitly mentions `?` for inline help; first-run also shows a 3-second toast: "Press ? for keyboard shortcuts". **Add to wave-3 spec.**

### Required changes (must apply before Wave 3 ships)

- D2 (legend in header)
- D3 (dead-state preview message)
- D4 (column degradation table)
- D7 (attached-session marker)

### Optional / nice-to-have

- D5, D6, D8 — apply if cheap; skip if pressed for time.

### Out of scope for this review

- Color theme customization (v0.3+)
- Full Nerd Font icon variant (Task 011 deferred to v0.3)
- ANSI true-color vs. 256-color fallback (assume 256 minimum, document)

---

## DX Review

**Reviewer:** Claude (Opus 4.7), self-review framed as developer experience / install UX
**Date:** 2026-05-08
**Verdict:** 🟡 **CONDITIONAL GO**

### Scope

Reviewed against Wave 1 (install paths), Wave 4-B (plugin install), Wave 5 (release one-liner).

### Strong points

| Aspect | Verdict | Notes |
|--------|---------|-------|
| `PTTY_DIR` env-var | ✅ Excellent | Override-friendly for devs (`PTTY_DIR=$PWD ./install.sh`); standard pattern |
| Pre-flight checks | ✅ Strong | tmux ≥ 3.2 + fzf ≥ 0.30 with copy-paste upgrade hints |
| Idempotent install | ✅ Good | rsync --delete pattern, re-runnable |
| Symlink shim for legacy | ✅ Pragmatic | One release cycle; doesn't break existing users |
| Modular wave docs | ✅ Excellent | Agent can pick one wave file, complete in isolation |
| Test pyramid | ✅ Strong | bats unit + smoke + CI matrix on tmux versions |

### Issues found

#### X1 — `curl | bash` with no checksum (HIGH)
**Finding:** Wave 5 ships `curl -sSL https://ptty.zentala.io/install | bash` as the headline install. Trust-by-default, no checksum, no GPG sig.
**Severity:** High — security-conscious users will refuse; hostile DNS / MITM scenarios.
**Action:** README documents both:
1. Headline: `curl … | bash` (convenience)
2. Alternative: `git clone https://github.com/zentala/ptty && cd ptty && ./install.sh` with note "inspect before running".
3. Future v0.3: GPG-signed install script + checksum file. **Document as backlog item.**

#### X2 — install.sh failure modes don't show recovery hints (MEDIUM)
**Finding:** "TPM clone failed; check network" is unhelpful. User doesn't know if they should retry, configure proxy, run offline mode.
**Severity:** Medium — install-blocker → user gives up.
**Action:** Each failure point in `install.sh` prints:
```
ERROR: <what failed>
WHY: <likely cause>
FIX: <copy-paste recovery>
```
Example:
```
ERROR: Could not clone TPM from github.com
WHY:   No network, blocked by firewall, or git not installed
FIX:   1. Check network: curl -I https://github.com
       2. Retry: ./install.sh
       3. Offline: download release tarball from https://github.com/zentala/ptty/releases
```
**Update wave-1 + wave-4-b spec.**

#### X3 — Uninstall removes plugins but not user data (LOW)
**Finding:** `uninstall.sh` removes `$PTTY_DIR` but resurrect saves live in `$PTTY_DIR/state/resurrect/`. User who reinstalls expects their saved layouts back; they're gone.
**Severity:** Low — uncommon scenario.
**Action:** Move resurrect dir to `${XDG_DATA_HOME:-$HOME/.local/share}/ptty/resurrect/`. Survives uninstall. Re-install picks it up. **Update wave-4-b spec + ARCHITECTURE.md §H.**

#### X4 — No `ptty doctor` diagnostic (MEDIUM)
**Finding:** When something doesn't work, user has no single command to dump versions, paths, plugin state, recent log lines.
**Severity:** Medium — every issue report becomes "run these 6 commands and paste output".
**Action:** Ship `bin/ptty-doctor` that prints:
```
pTTY version:    v0.2.0
PTTY_DIR:        /home/x/.ptty
tmux version:    3.5a (OK, ≥3.2)
fzf version:     0.44.1 (OK, ≥0.30)
Plugins:
  tpm:               ✓ installed
  resurrect:         ✓ installed
  continuum:         ✓ installed (last save: 12 min ago)
  which-key:         ✗ MISSING
systemd unit:    ✓ enabled, running
Recent log:
  …last 10 lines…
```
**Add as new acceptance criterion in wave-5.**

#### X5 — macOS path missing from Wave 5 (HIGH)
**Finding:** Wave 5 mentions macOS in PRD compatibility but `install.sh` codepath has no macOS-specific handling. systemd doesn't exist; LaunchAgent is needed for boot autostart.
**Severity:** High — claims macOS support but no macOS test path.
**Action:**
1. Wave 5 ships **without** boot-autostart on macOS. README documents: "On macOS, add `tmux -f ~/.ptty/tmux.conf` to your shell rc for now. LaunchAgent in v0.3."
2. CI matrix adds `macos-latest` runner — at minimum `install.sh` must succeed on macOS.
**Update wave-5 acceptance + scope.**

#### X6 — No `make` target for common ops (LOW)
**Finding:** Devs working on pTTY itself need to know "to test the popup, run `tmux -L test -f $PWD/tmux.conf` then send-keys". No `Makefile` target.
**Severity:** Low — dev-only friction.
**Action:** Ship `Makefile`:
```make
dev:        ## Run tmux with current repo conf
	tmux -L ptty-dev -f $$PWD/tmux.conf

test:       ## Run all bats tests
	bats tests/unit tests/smoke

lint:       ## shellcheck + grep guards
	shellcheck src/**/*.sh install.sh uninstall.sh

clean:
	tmux -L ptty-dev kill-server 2>/dev/null || true

install-dev: ## Install in-place from current clone
	PTTY_DIR=$$PWD ./install.sh
```
**Add to wave-5 spec.**

#### X7 — README install one-liner unclear about TPM permissions (LOW)
**Finding:** TPM clones into `$PTTY_DIR/plugins/tpm`. If user previously had TPM at `~/.tmux/plugins/tpm`, our copy duplicates it. Confusing.
**Severity:** Low — disk waste, potential confusion.
**Action:** Wave 4-B: detect existing `~/.tmux/plugins/tpm`, document that pTTY has its own isolated copy (intentional — pTTY conf shouldn't depend on user's other tmux setup). README mentions this. **Add note to wave-4-b spec.**

#### X8 — Migration banner is one-shot only (LOW)
**Finding:** `install.sh` prints migration notice on first run. User who runs `tmux source-file` afterwards never sees it.
**Severity:** Low — informational.
**Action:** First-time first-tmux-start hook (tmux user-option `@ptty_first_run`) shows a 5-sec banner in status bar: "Welcome to pTTY. Press F12 for help." Cleared after dismiss. **Optional, add to wave-5 backlog.**

### Required changes (must apply before v0.2 ships)

- X1 (document `git clone` install alternative — security)
- X2 (failure-mode recovery hints)
- X3 (resurrect data outside $PTTY_DIR)
- X4 (`ptty-doctor` command)
- X5 (macOS reality check)

### Optional

- X6 (Makefile)
- X7 (TPM dup note)
- X8 (welcome banner)

### Risk if not addressed

- X1 → security incident posted on HN, brand damage
- X4 → every issue report takes 3 round-trips, maintainer burnout
- X5 → macOS users hit broken paths, file bad reviews

### Out of scope for this review

- Homebrew tap (v0.3 explicitly)
- Debian/RPM packages (v0.3+)
- Telemetry / analytics (out of scope per PRD §7)

---

## Outstanding clarifications

These weren't in Q1–Q5 but may surface during implementation:

| ID | Question | Default if not asked |
|----|----------|---------------------|
| Q-A | Should `n` (new) prompt for slot or auto-pick lowest free? | Auto-pick. Drag-reorder later. |
| Q-B | Should F11 show stopped containers (auto-sleep wake-up state)? | Out of scope for tmux-only. Revisit if pTTY learns about Docker. |
| Q-C | Should rename (`R`) update slot label or just window name? | Window name only; slot identity is structural. |
| Q-D | Should `K` kill require typing the slot number to confirm (vs. Enter)? | No — confirm dialog with default Cancel is enough. |
| Q-E | Should we ship a "demo" tmux conf for asciinema recordings? | Yes — `examples/demo.conf` for reproducible README GIFs. |

If any of these block implementation, the wave file should call them out and force a decision before starting.
