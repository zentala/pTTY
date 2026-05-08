# Task 017: Rewrite Mission Control in Go (bubbletea)

**Status:** 📋 BACKLOG (v1.0 — long-term)
**Priority:** LOW (strategic)
**Created:** 2026-05-08

---

## Goal

Replace bash + fzf mission-control / help-popup with a single Go binary built on **bubbletea** (charm.sh TUI framework).

## Why

- One static binary, zero runtime deps (no fzf / gum / bash quirks)
- Real state machine, not parsed display rows
- Cross-platform (Linux/macOS/BSD) without bash-isms
- Looks/feels like lazygit, k9s, gh — proper TUI standard
- Easier to test (Go test framework vs. bats)
- Pre-built binaries via GoReleaser → `brew install ptty`

## Scope

- `cmd/ptty/` — main CLI: `ptty manager`, `ptty help`, `ptty new`, `ptty kill <n>`, `ptty list`
- `internal/tmux/` — wrapper around `tmux` commands (typed)
- `internal/ui/` — bubbletea models for Manager and Help screens
- Replace shell scripts; tmux.conf binds to `ptty` binary instead of `.sh` files

## Risks

- Adds Go toolchain to dev requirements
- Loses "just bash, easy to fork" simplicity
- Binary distribution overhead (releases, signing, homebrew tap)

## Decision criteria

Don't start until v0.3 stable. If bash version hits maintenance burden (bug reports about quoting / path / portability), accelerate.

## Out of scope (until decided)

- Full pTTY daemon (separate process managing sessions) — overkill, tmux already does this
