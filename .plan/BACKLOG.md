---
name: BACKLOG
description: Pre-epic ideas for pTTY — things worth doing but not scoped to a current epic yet
updated: 2026-06-19
---

# pTTY BACKLOG

Loose ideas that haven't been promoted to an epic yet. When something here gets picked up,
move it into `.plan/epic-<version>-*/` with proper PLAN.md + tasks.

---

## Installer / Daemon UX

### [ ] `ptty daemonize` CLI command

- **Idea**: explicit user-facing command to manage the tmux daemon lifecycle.
  Today `install.sh` enables systemd+linger by default, which is the right default
  (see CLAUDE.md rule #8) — but there's no neutral user-facing verb for "start the
  daemon" / "ensure it's running" / "check if it's running". `ptty daemonize` would
  be that command.
- **Why**: discoverable. A user who skipped systemd at install time (planned
  `--no-systemd` flag, see below) still needs a way to manually bring the daemon
  up without copy-pasting `systemctl --user start ...` from docs.
- **Scope sketch**:
  - `ptty daemonize` — start tmux daemon if not running (idempotent)
  - `ptty daemonize --status` — report running/not-running + uptime
  - `ptty daemonize --enable-boot` — opt back into systemd autostart later
  - `ptty daemonize --disable-boot` — opt out of systemd autostart
- **Note**: currently pTTY does NOT do any explicit daemonize step. tmux just gets
  spawned on first session creation. This command would formalize the lifecycle
  into something users (and the README) can talk about.
- **Not urgent**: autostart-by-default covers the 95% case. This is for power users
  and for honesty in docs.

### [ ] `install.sh --no-systemd` opt-out flag

- **Idea**: let users decline the systemd autostart at install time, either via
  `--no-systemd` flag or an interactive prompt.
- **Why**: CLAUDE.md rule #8 mentions opt-out as a planned escape hatch. Some
  users (shared hosts, restricted environments, anti-systemd preference) won't
  want linger enabled.
- **Default stays autostart-on** (per user decision 2026-05-23). This is opt-out,
  not opt-in.

---

## Docs / Marketing

### [ ] Pre-promotion visual polish for F11/F12

- **Goal**: make the two interactive product surfaces look launch-ready before
  recording any promotional asset.
- **Why**: the promo video will mostly sell the F-key workflow. If F11 Manager or
  F12 Help look unfinished, the video will amplify that weakness.
- **Scope sketch**:
  - Review F11 Manager layout, spacing, status labels, active-slot marker, and
    empty-slot rendering on common terminal sizes.
  - Review F12 Help grouping, scanability, key labels, close affordance, and
    consistency with the actual tmux bindings.
  - Validate both views in a Nerd Font terminal and in a plain terminal.
  - Capture before/after screenshots for release notes and future regressions.
- **Exit criteria**: F11 and F12 are good enough to be the hero frames of the
  launch video without explanatory copy.
- **Dependency**: do this before the animated demo/video task below.

### [ ] Terminal icon fallback demo mode

- **Goal**: make the non-Nerd-Font/fallback icon view intentional enough to show
  in the launch video or screenshots.
- **Why**: many developers will first try pTTY in a terminal that does not have a
  Nerd Font installed. Showing graceful fallback builds trust and avoids a
  "works only on my terminal" impression.
- **Scope sketch**:
  - Audit `src/theme-config.sh` fallback icons and status bar rendering.
  - Add a documented way to force fallback icons for QA/demo recording, for
    example an environment variable or tmux option.
  - Ensure F11/F12 and the status bar remain aligned without Nerd Font glyphs.
  - Decide whether the launch video shows both modes or keeps fallback as a
    screenshot-only proof.
- **Exit criteria**: fallback rendering is visually coherent and reproducible for
  the demo script.
- **Priority**: optional for promotion if it threatens video timing, but do it
  before launch if the fallback view currently looks broken.

### [ ] Animated demo — SSH login + F-key tour (asciinema / vhs / similar)

- **Goal**: pierwsze animowane demo pokazujące kluczowy use case pTTY.
- **Promotion priority**: highest. The video/GIF is the main launch asset; do not
  start broad promotion without it.
- **Preconditions**:
  - F11/F12 visual review is complete.
  - Fallback icon mode is either polished and included, or explicitly deferred
    from the launch video.
- **Scenariusz nagrania** (do dopracowania, draft):
  1. Otwarty terminal na laptopie A (lokalny shell)
  2. `ssh server` (SSH alias z `~/.ssh/config` z `RemoteCommand tmux attach …`)
  3. Po zalogowaniu widać pTTY — hero status bar na dole z F1–F12
  4. Pierwszy terminal aktywny (F1) — np. `htop` lub `ls`, coś żywego
  5. `Ctrl+F2` → drugi terminal (np. logi, `tail -f`)
  6. `Ctrl+F3` → trzeci (edytor, np. `nvim` z otwartym plikiem)
  7. Skok do `Ctrl+F10` — pokazać że to ostatni "główny" terminal (auto-created
     na żądanie, dowód że pTTY ma 10 slotów na pracę)
  8. `Ctrl+F11` → Manager Menu (interaktywny TUI, podgląd wszystkich konsol)
  9. `Ctrl+F12` → Keyboard cheatsheet / Help Reference
  10. **Bonus (jeśli mieści się w czasie)**: rozłączenie SSH (Ctrl+D z `~.` lub
      symulacja drop), ponowny `ssh server`, dowód że sesje, scrollback i
      stan procesów przeżyły.
- **Stack**: `vhs` (charm.sh) jako primary — deterministyczny scenariusz w
  `.tape` file, generuje GIF do README **i** `.cast` do landingu w jednym
  przejściu. Alternatywa: `asciinema rec` ręcznie + ręczna konwersja.
- **Hosting**: GIF wersja → `docs/images/ptty-demo.gif` w repo (analogicznie do
  hero screenshot). `.cast` wersja → docelowo `cdr.zentala.io` lub bezpośrednio
  obok landingu jak powstanie.
- **Czas**: ~2h na pierwsze nagranie + scenariusz, potem regeneracja jest minutowa.
- **Why**: README z hero PNG jest dobry, ale animacja sprzedaje pTTY w 5 sekund.
  Niezbędne przed publicznym push (HN / Reddit / social).
- **Anti-NIH check przy realizacji**: zanim napiszesz `.tape` od zera, sprawdź
  `gh search repos vhs tmux` / charm examples — może da się sklonować istniejący
  scenariusz tmuxowy i tylko podmienić komendy na pTTY-specific.
- **README hero**: nowy GIF idzie OBOK obecnego PNG (`docs/images/ptty-console.png`),
  nie zamiast — PNG ładuje się natychmiast, GIF dodaje ruch dla zainteresowanych.
- **Pełen kontekst**: `.plan/reports/2026-05-23-website-and-asciinema.md`

### [ ] Promotion channel plan

- **Goal**: prepare a lightweight public-promotion plan after the video is ready.
- **Channels**:
  - Reddit communities for terminal, self-hosting, homelab, Linux, and developer
    tooling audiences.
  - Facebook developer and self-hosting groups where terminal tooling posts are
    accepted by the group rules.
  - Hacker News / social posts only after README, install path, and demo asset are
    stable.
- **Message angle**: "keep Claude Code / Codex / Gemini CLI / Aider sessions
  alive over SSH and switch them with F-keys."
- **Launch order**:
  1. Publish README with final GIF/video and screenshots.
  2. Post to a small friendly/dev group first and collect wording objections.
  3. Fix obvious confusion in README/F12.
  4. Post to Reddit and larger dev communities.
  5. Consider Hacker News only when install and support flow can handle traffic.
- **Exit criteria**: each channel has a short post draft, target URL, expected
  first response, and a support checklist using `ptty-doctor`.

### [ ] Landing page (`ptty.sh` lub `ptty.dev`)

- **Goal**: jednostronowy landing na Cloudflare Pages, hero z animacją asciinema,
  3 bullety "protects against", install one-liner, link do GitHub.
- **Trigger**: po v0.2 release + po nagraniu animowanego demo (poprzedni task).
- **Decyzje do podjęcia**: domena, hosting demo (asciinema.org vs self-host),
  stack landingu — szczegóły w `.plan/reports/2026-05-23-website-and-asciinema.md`.
- **Nie blokuje** wcześniejszej pracy nad pTTY, czysto marketingowe.

### [ ] Reshoot hero screenshot with `you@server.lan`

- **Current**: `docs/images/ptty-console.png` shows `zentala @ server.lan` —
  documented as an accepted exception to placeholder rule #10.
- **Next reshoot**: use `you@server.lan` (cleaner generic placeholder, still looks
  natural — `.lan` suggests a real homelab context without naming a person).
- **Trigger**: next time the status bar UI changes meaningfully, or before any
  marketing push (HN, Reddit, social).
