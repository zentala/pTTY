# Task 016: Evaluate & Adopt tmux Plugin Stack

**Status:** 📋 BACKLOG (v0.3)
**Priority:** MEDIUM
**Created:** 2026-05-08

---

## Goal

Evaluate established tmux plugins and decide which to adopt vs. roll our own. Don't reinvent what already exists.

## Plugins to evaluate

| Plugin | Use case in pTTY | Decision needed |
|--------|------------------|-----------------|
| **TPM** (`tmux-plugins/tpm`) | Plugin manager, prerequisite for the rest | **Adopt** — standard |
| **tmux-sessionx** (`omerxx/tmux-sessionx`) | F11 Manager — popup with sessions, kill, rename, switch | Adopt vs. own implementation (Task 014) |
| **tmux-which-key** (`alberti42/tmux-which-key`) | F12 Help — discoverable bindings | Adopt vs. own (Task 015) |
| **tmux-resurrect** (`tmux-plugins/tmux-resurrect`) | Save/restore session layout across reboot | **Adopt** — fits "persistent" branding |
| **tmux-continuum** (`tmux-plugins/tmux-continuum`) | Auto-save resurrect every 15min | **Adopt** with resurrect |
| **tmux-menus** (`jaclu/tmux-menus`) | Popup menus for tmux ops | Skip — overlaps with sessionx |
| **tmux-fzf** (`sainnhe/tmux-fzf`) | fzf-based switcher | Skip if sessionx adopted |
| **extrakto** (`laktak/extrakto`) | Grab text from pane history | Optional bonus feature |
| **tmux-thumbs** (`fcsonline/tmux-thumbs`) | Vimium-like text jumping | Optional |
| **tmux-floax** | Floating popup pane | Skip — display-popup is enough |

## Method

1. Spin up clean tmux config in `/tmp/ptty-eval/`
2. Install one plugin at a time, drive it through pTTY's actual workflows
3. Score each on: UX fit, maintenance status (commits last 6 months), config complexity, conflicts with pTTY bindings (esp. F1-F12)
4. Document decision in ADR: `03-architecture/adr-006-plugin-stack.md`

## Constraint

pTTY's value prop is "zero-config persistent terminal" — every adopted plugin must:
- Install automatically via `install.sh`
- Have sensible defaults (no user config required)
- Not conflict with F1-F12 bindings
- Degrade gracefully if missing

## Acceptance

- ADR written with adopt/skip decision per plugin
- `install.sh` installs adopted plugins via TPM
- Smoke test: fresh install on clean VM → all features work without manual config
