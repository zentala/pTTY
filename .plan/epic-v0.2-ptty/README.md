# Epic: pTTY v0.2 Launch — Deep Refactor

**Architecture:** [ARCHITECTURE.md](ARCHITECTURE.md) ← read this first
**Product:** [PRD.md](PRD.md)
**Reviews:** [REVIEW.md](REVIEW.md)
**Status:** APPROVED — Q1–Q5 decisions locked, ready to execute
**Author:** zentala + Claude (Opus 4.7), 2026-05-08
**Target:** v0.2 public release · ~9 working days

---

This epic ships **pTTY v0.2** — first public release of the project (renamed from `tmux-persistent-console`). Deep refactor: universal install paths, popup-based F11 Manager and F12 Help, plugin stack for cross-reboot persistence, modular codebase ready for future Go rewrite.

**One-liner:** "SSH disconnect-proof terminal sessions with a real UI, not a status bar."

**Today's reality:** F11/F12/Ctrl+H/Ctrl+R all silently fail because `tmux.conf` references a nonexistent `~/.vps/sessions/` path. Fixing that (Wave 1) unblocks everything else.

---

## Locked decisions (Q1–Q5)

See [`02-planning/mockups/decisions.html`](../../02-planning/mockups/decisions.html) for the full discussion.

| # | Decision | Choice |
|---|----------|--------|
| Q1 | Path universality | env-var `PTTY_DIR` + sed-template in `install.sh` |
| Q2 | Plugin vs. own | Hybrid: own F11, `tmux-which-key` for F12 |
| Q3 | Kill key in F11 | `K` (shift) — lazygit/k9s convention |
| Q4 | tmux < 3.2 fallback | Popup-only, document min version |
| Q5 | Branding | Full pTTY rebrand in v0.2 |

---

## Subagent workflow (read before starting)

Same convention as `epic-external-domains`: **one task = one worktree = one branch = one PR.** Pick the next unchecked task in the **current wave**, work to all acceptance criteria in that wave file, push, PR, merge, tick the box, close the agent.

**Wave gates:** do NOT start Wave N until **all** Wave (N-1) tasks are merged. Within a wave, tasks may run in parallel unless the wave file says otherwise.

---

## Wave 1 — Foundation (BLOCKER, days 1–2)

Without this, nothing else can be tested. Today F11/F12/Ctrl+H/Ctrl+R all silently fail.

- [ ] [wave-1-paths.md](wave-1-paths.md) — `PTTY_DIR` env-var, sed-template in `install.sh`, eliminate every `~/.vps/sessions/` reference, CI guard, fix `manager-menu.sh` vs. `mission-control.sh` filename mismatch.

## Wave 2 — Core refactor (days 3–4, parallel)

Split current monolith into testable modules. Unblocks Wave 3.

- [ ] [wave-2-a-state-module.md](wave-2-a-state-module.md) — `src/core/state.sh`: console list, slot allocation, status detection (live/idle/sleep/dead/slot), 5s in-memory cache.
- [ ] [wave-2-b-actions.md](wave-2-b-actions.md) — `src/actions/{attach,kill,restart,rename,new,detach}.sh`. Each callable from CLI, atomic, unit-testable.
- [ ] [wave-2-c-lib.md](wave-2-c-lib.md) — `src/lib/{tmux,format,ps}.sh` — typed-ish wrappers, no more `awk '{print $3}'` on display rows.

## Wave 3 — F11 Manager popup (days 5–7, sequential)

The brand-defining UX. After this, you have a demo.

- [ ] [wave-3-f11-manager.md](wave-3-f11-manager.md) — `src/ui/manager.sh` popup, all single-key actions (Enter/K/r/R/n/j/k/1-0/?/q), live preview, slot-aware rendering, sleep state column.

## Wave 4 — F12 Help + plugin stack (day 8, parallel)

- [ ] [wave-4-a-f12-help.md](wave-4-a-f12-help.md) — adopt `alberti42/tmux-which-key`, annotation pass on `tmux.conf`, fallback `src/ui/help.sh` if plugin missing.
- [ ] [wave-4-b-plugin-stack.md](wave-4-b-plugin-stack.md) — TPM + `tmux-resurrect` + `tmux-continuum` installed by `install.sh`. ADR-006 written.

## Wave 5 — Rebrand + release (day 9, sequential after Wave 4)

- [ ] [wave-5-rebrand-release.md](wave-5-rebrand-release.md) — GitHub repo rename to `ptty`, README rewrite + 2 GIFs (F11, F12), `ptty.zentala.io` GitHub Pages, CHANGELOG with migration, bats CI smoke green, `install.sh` one-liner published.

---

## Status board

```
Wave 0  [██████████] DONE   decisions locked, mockups built (Q1–Q5)
Wave 1  [░░░░░░░░░░] TODO   path universality (BLOCKER for everything)
Wave 2  [░░░░░░░░░░] TODO   core refactor (state, actions, lib)
Wave 3  [░░░░░░░░░░] TODO   F11 popup
Wave 4  [░░░░░░░░░░] TODO   F12 + plugins
Wave 5  [░░░░░░░░░░] TODO   rebrand + release
```

---

## Dependencies graph

```
Wave 1 (paths)
  ├─→ Wave 2-a (state)
  │     └─→ Wave 3 (F11)
  ├─→ Wave 2-b (actions) ┘
  ├─→ Wave 2-c (lib)     ┘
  ├─→ Wave 4-a (F12)
  └─→ Wave 4-b (plugins)
        ↓
       Wave 5 (release)
```

---

## Out of scope (deferred to v0.3 / v1.0)

| Item | Why not now | Where |
|------|-------------|-------|
| Multi-select in F11 | UX complexity, not core | v0.3 |
| Drag-to-reorder F-slots | Nice-to-have | v0.3 |
| Cross-host sessions | Different product | never |
| Go + bubbletea rewrite | Premature; bash works | v1.0 — task 017 |
| Per-context F12 help | Polish | v0.3 |
| Web dashboard | Different product | never |
| Inline tutorial mode | Polish | v1.0 |

---

## Definition of Done (v0.2 release)

- [ ] `git clone https://github.com/zentala/ptty && ./install.sh` on clean Debian 12 VM → working pTTY in <60s
- [ ] F1–F10 jump to console works
- [ ] F11 opens popup, all single-key actions work, no pseudo-session in `list-sessions`
- [ ] F12 opens popup with current bindings auto-rendered
- [ ] Host reboot → continuum restores sessions
- [ ] `grep -rE "vps/sessions|tmux-persistent-console" .` returns only CHANGELOG/migration references
- [ ] README has 2 GIFs (F11 demo, F12 demo)
- [ ] `ptty.zentala.io` GitHub Pages live
- [ ] bats smoke test green on tmux 3.2 / 3.5 / latest
- [ ] CHANGELOG.md complete with migration section
- [ ] GitHub Release published with one-liner install command

---

## Review log

| Review | Trigger | Status | Findings |
|--------|---------|--------|----------|
| CEO Review | self-review (Claude Opus 4.7) | DONE 2026-05-08 | GO with conditions: README GIFs mandatory, plugin decision now, branding consistent, Task 013 ship-blocker. See [REVIEW.md §CEO](REVIEW.md). |
| Eng Review | self-review (Claude Opus 4.7) | DONE 2026-05-08 | CONDITIONAL GO: PTTY_DIR pattern OK, popup-only OK, fzf version check needed, parser must not use display-row awk. See [REVIEW.md §Eng](REVIEW.md). |
| Design Review | self-review (Claude Opus 4.7) | DONE 2026-05-08 | CONDITIONAL GO: 8 findings (4 required: legend in header, dead-state preview msg, 80-col degradation table, attached-session marker). See [REVIEW.md §Design](REVIEW.md). |
| DX Review | self-review (Claude Opus 4.7) | DONE 2026-05-08 | CONDITIONAL GO: 8 findings (5 required: doc git-clone alt, recovery hints, resurrect outside PTTY_DIR, ptty-doctor, macOS reality check). See [REVIEW.md §DX](REVIEW.md). |

---

## References

- **Mockups:** [`02-planning/mockups/f11-f12-redesign.html`](../../02-planning/mockups/f11-f12-redesign.html)
- **Decisions doc:** [`02-planning/mockups/decisions.html`](../../02-planning/mockups/decisions.html)
- **Existing tasks (legacy single-file):** `04-tasks/012`–`017.md`, `04-tasks/001`–`005.md` — kept for traceability; this epic supersedes them. Each wave file references the corresponding task ID.
- **Code standards:** `03-architecture/CODE-STANDARDS.md` (existing, complete)
- **Testing strategy:** `03-architecture/testing-strategy.md` (existing, complete)
- **Convention reference:** mirrors `/opt/zntl-local-servers/.plan/epic-external-domains/`
