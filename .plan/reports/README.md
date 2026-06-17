---
name: reports-index
description: Advisory / research / decision reports — context behind backlog and roadmap choices
---

# Reports

Long-form documents that capture the **reasoning** behind a decision or a
recommendation. Not actionable themselves — the actionable bit lands in
`BACKLOG.md` or an epic plan. Reports exist so we can come back and ask
"why did we decide that?" without re-doing the analysis.

## Filename

`YYYY-MM-DD-short-slug.md` — date first so it sorts chronologically.

## Frontmatter `status` vocab

Pick one. Add to the vocab here when a new type genuinely doesn't fit.

| Status | Meaning |
|--------|---------|
| `advisory` | "Here are options + a recommendation, user/team picks." Default. |
| `decision` | A choice has been made and recorded. Future work follows this. |
| `research` | Pure investigation — what's possible, what exists, what it costs. No recommendation yet. |
| `retro` | Looking back at something that already happened — what worked, what didn't. |

## Index

- [2026-05-23 — Website + asciinema for pTTY](2026-05-23-website-and-asciinema.md) — `advisory`
