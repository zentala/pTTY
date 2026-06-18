---
name: website-and-asciinema
description: Should pTTY have a marketing website? What is asciinema, what does it cost, how to use it for pTTY demo?
date: 2026-05-23
status: advisory
---

# Raport: strona internetowa dla pTTY + asciinema jako demo

Decyzja oczekuje na użytkownika. Ten dokument zbiera argumenty i opcje techniczne,
żeby było do czego wrócić przy planowaniu landingu (najprawdopodobniej v0.3 cycle).

---

## 1. Czy warto zrobić stronę internetową dla pTTY?

**TL;DR: Tak, warto — ale dopiero przy v0.3+, nie teraz.**

### Za stroną
- pTTY targetuje ludzi spoza kręgu znajomych (HN, Reddit, dev twitter). README na
  GitHubie konwertuje gorzej niż landing — szczególnie dla osób ciekawych "co to
  jest" przed klonowaniem repo.
- Hero z animowanym demo (asciinema/GIF) sprzedaje pTTY w 5 sekund. README tego
  nie potrafi nawet z hero PNG.
- Infra już jest: Cloudflare Pages + `cdr.zentala.io`. Koszt zero, deploy w godzinę.
- Kanoniczny link `ptty.sh` / `ptty.dev` brzmi profesjonalniej niż
  `github.com/zentala/pTTY` przy udostępnianiu.

### Przeciw / czemu nie teraz
- v0.2 jeszcze w developmencie, install UX (`--no-systemd`, `ptty daemonize`)
  nieukończony. Landing teraz = ryzyko że za 2 tygodnie copy jest nieaktualne.
- Bez asciinema/wideo landing będzie słaby — a nagranie to osobny task.
- README po ostatnich poprawkach (hero PNG, value prop, F-key map) jest solidny —
  wystarczy do early adopters.

### Rekomendowana sekwencja
1. **Teraz**: zostaw README, dokończ v0.2 + nagraj asciinema/GIF (patrz sekcja 3).
2. **Przed pierwszym publicznym push (HN/Reddit)**: jednostronowy landing na
   Cloudflare Pages — hero asciinema, 3 bullety "protects against", install
   one-liner, link do GitHub. Reuse copy z `01-vision/VALUE-PROPOSITION.md`.
3. **Domena**: `ptty.sh` jeśli wolna (krótsza, shell-tooling vibe). Fallback `ptty.dev`.

---

## 2. Czym jest asciinema?

**asciinema** to narzędzie do nagrywania sesji terminala — nie jako wideo, tylko
jako **tekst + timing**. Plik wynikowy (`.cast`) waży kilobajty zamiast megabajtów,
a użytkownik na stronie może **zaznaczyć i skopiować tekst** prosto z "nagrania".
Wygląda jak film, działa jak terminal.

### Format `.cast`
JSON — każda linia: timestamp + bajty co poszły na ekran. Stąd mały rozmiar i
copy-paste. Plik diff-uje się czysto w gicie (jeśli przetrzymywać w repo).

### Workflow

```bash
# Instalacja (Linux/server)
sudo apt install asciinema

# Nagranie
asciinema rec ptty-demo.cast
# ...robisz co chcesz w terminalu...
# Ctrl+D żeby zakończyć

# Podgląd lokalnie
asciinema play ptty-demo.cast
```

### Koszt: 0 zł

Dwie opcje hostingu, obie darmowe:

**1. asciinema.org (oficjalny serwis)**
- `asciinema upload ptty-demo.cast` → link typu `asciinema.org/a/abc123`
- Embed: `<script src="https://asciinema.org/a/abc123.js"></script>`
- Plus: zero infra po naszej stronie
- Minus: SPOF — jeśli asciinema.org padnie, demo znika z naszej strony

**2. Self-hosted przez `asciinema-player` (rekomendowane dla pTTY)**
- `.cast` na własnym CDN: `cdr.zentala.io/ptty-demo.cast`
- Player JS (open-source, ~50KB) hostowany razem z landingiem
- Plus: atomowe z resztą strony, brak zależności od cudzego serwisu, spójne z
  decyzją z tej sesji o trzymaniu hero screenshota w repo zamiast na zewnętrznym CDN

```html
<link rel="stylesheet" href="/asciinema-player.css">
<div id="demo"></div>
<script src="/asciinema-player.min.js"></script>
<script>
  AsciinemaPlayer.create('/ptty-demo.cast', document.getElementById('demo'));
</script>
```

---

## 3. Alternatywy do asciinema

| Narzędzie | Output | Działa w README GitHub? | Copy-paste? | Best for |
|-----------|--------|-------------------------|-------------|----------|
| **asciinema** | `.cast` JSON | nie (potrzebny player JS) | tak | landing page |
| **vhs** (charm.sh) | GIF / MP4 / WebM / `.cast` | tak (GIF) | tylko `.cast` | README + landing (deterministyczne, regenerowalne) |
| **terminalizer** | GIF | tak | nie | quick demo |
| **OBS screencast** | MP4 | nie (link do YT) | nie | overkill dla terminala |

### Rekomendacja: `vhs` + asciinema

- **README**: GIF z `vhs` (GitHub renderuje natywnie, działa wszędzie)
- **Landing page**: asciinema self-hosted (copy-paste install commands prosto z dema)

`vhs` pozwala napisać scenariusz w `.tape` file (jak skrypt) i deterministycznie
generować GIF/MP4/`.cast`. Świetne do CI — można regenerować demo po każdej zmianie
status bara / F-key map bez ponownego ręcznego nagrywania.

---

## 4. Scenariusz pierwszego demo

Demo ma pokazać kluczowy use case pTTY (SSH drop survival + F-key switcher).
**SSOT scenariusza**: `.plan/BACKLOG.md` (task "Animated demo — SSH login + F-key tour").
Tu jest tylko skrót — przy zmianach edytuj BACKLOG, nie ten raport.

Skrót: SSH z laptopa A na serwer → widzimy pTTY → przełączamy F1→F2→F3 →
skok do F10 (ostatni terminal) → F11 (manager / podgląd terminali) →
F12 (help / cheatsheet). Bonus: rozłączenie SSH w trakcie i reconnect z
dowodem że sesje przeżyły.

---

## 5. Decyzje do podjęcia (do potwierdzenia przez użytkownika)

- [ ] **Domena landingu**: `ptty.sh` vs `ptty.dev` vs inne — sprawdzić dostępność
- [ ] **Hosting demo**: asciinema.org vs self-hosted na `cdr.zentala.io`
      (rekomendacja: self-hosted, spójne z decyzją z tej sesji)
- [ ] **Stack landingu**: czysty HTML/CSS na Cloudflare Pages vs Astro vs coś
      innego z ekosystemu (np. spójność z `infopill.news` / `zentala.eu`)
- [ ] **Kiedy**: po v0.2 release czy razem z v0.3?

Te decyzje nie blokują nagrania demo — `vhs`/asciinema można zrobić od razu i
użyć w README, a landing podpiąć później.
