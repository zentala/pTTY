---
id: E002-T06
title: Harden CI release gates
status: completed
priority: high
effort: medium
type: improvement
dependencies: [E002-T05]
tags: [ci, tests, installer, release-gate]
epic: E002
branch: feat/E002-T06-ci-release-gates
group: epic-v0.2-ptty
created: 2026-06-15
completed_at: 2026-06-18
---
# E002-T06: Harden CI release gates

## Objective

Make CI fail on the regressions found in the pre-release review instead of
turning them into warnings or hiding failures.

## Acceptance Criteria

- [x] ShellCheck failures fail CI for release-relevant scripts.
- [x] tmux config parse failures fail CI.
- [x] CI checks all script paths referenced by `src/tmux.conf`.
- [x] CI checks remote installer file coverage against `src/tmux.conf`.
- [x] Docker/session-count assertions match the chosen F1-F10 product model.
- [x] Markdown link checking covers README, Claude files, and release docs.

## Tests

- GitHub Actions run on a PR.
- Local equivalent commands documented in `tools/README.md` or task notes.

## Notes

Existing examples to fix: `shellcheck "$script" || echo`, `tmux -f src/tmux.conf ... || true`,
and Docker tests expecting 7 sessions.

CI now runs blocking ShellCheck/tmux gates for release-relevant scripts, checks
`tools/check-tmux-references.sh`, and validates README/CLAUDE markdown links.
