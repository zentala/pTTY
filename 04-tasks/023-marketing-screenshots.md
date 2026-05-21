# Task 023: Marketing — screenshots / visual presentation pass

**Status:** Pending (backlog)
**Priority:** Medium (gates public launch alongside tasks 020/021)
**Type:** Marketing / DevEx / README
**Estimated effort:** 2–4 hours (depends on tooling chosen)
**Depends on:** 019 (final console model), 020 (README DevEx pass)
**Related:** D2 acceptance criterion in [020-readme-devex-pass.md](020-readme-devex-pass.md) (hero visual)

---

## Context

We need to look at how comparable projects present themselves visually — screenshots, terminal recordings, animated GIFs, embedded asciinema — and apply the best ideas to pTTY's README and (eventually) a small landing page.

**Reference to study:** [standardagents/dmux](https://github.com/standardagents/dmux) — someone built something thematically similar (tmux + AI workflow) and the way they describe it / show it visually is worth dissecting before we publish ours. Open the repo, screenshot the hero, note:

- What's the first visual a visitor sees? (static screenshot? GIF? asciinema? terminal mock?)
- How do they convey the "tmux + AI" mental model without a wall of text?
- What captions / annotations sit alongside the visuals?
- Where do screenshots appear in the flow (hero / features / quick start / examples)?
- File format + size (PNG / SVG / WebM / GIF) — what loads fast on GitHub?

Then audit our README for the same beats and decide what's missing.

## Acceptance Criteria

- [ ] **Competitive scan**: Notes file under `docs/marketing/competitive-visuals.md` capturing what dmux (and 2–3 other tmux-adjacent / AI-CLI projects — zellij, tmuxinator, opencode, aider) do for hero visuals. One paragraph per project + screenshot of their hero.
- [ ] **Visual inventory of ours**: List every visual currently in our README + docs. Note resolution, format, age, whether it still matches v0.2 UI.
- [ ] **Hero recording**: At least one of:
  - asciinema cast of install → SSH attach → Ctrl+F2 switch → Ctrl+F11 manager (~30s)
  - OR animated SVG / WebM equivalent
  - Stored in `docs/assets/`, embedded under the tagline (satisfies 020-D2)
- [ ] **Feature screenshots**: Static screenshots for the three load-bearing visuals:
  - Status bar with F-key tabs (clean session, no Claude history pollution)
  - F11 manager menu open
  - F12 cheatsheet open
- [ ] **Caption discipline**: Every visual has a one-line caption explaining what the reader is looking at — not just "screenshot".
- [ ] **Consistency**: Terminal font, color scheme, prompt, and hostname identical across all screenshots. No mixing of personal dotfiles with generic demo dotfiles.
- [ ] **Placeholder hostnames** in every visible prompt — `user@tmux.example.com`, never the maintainer's real domain (see CLAUDE.md rule #10).

## Out of scope

- Building a landing page on a real domain — that's a separate task (zentala.io / a dedicated pTTY page).
- Logo / brand identity work — pTTY mark is already settled; this task is presentation of the product, not redesigning it.

## Notes

- Keep total README image weight under ~500 KB. Lean on SVG / asciinema over multi-MB GIFs.
- Re-record every visual the day we tag a release — screenshots rot fast when status bar / F-keys change.
