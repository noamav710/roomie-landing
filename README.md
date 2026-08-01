# roomie-landing

Static marketing/waitlist page for Roomie — Beer Sheva student housing.
No build step: `index.html` is self-contained (Tailwind-free, plain CSS,
Google Fonts CDN for type). Deploy as-is to GitHub Pages; `CNAME` points it
at `roomie.co.il`.

## What's here

- `index.html` — the page. Hero, "how it works", lister pitch, trust
  section, waitlist email capture (currently a `mailto:` form — there's no
  backend yet, so submissions open the visitor's email client addressed to
  `noam123av@gmail.com`).
- `assets/` — logo exports copied from `roomie/assets/images/` (icon,
  favicon, tab-bar mark). The nav/footer brand mark is inlined as SVG
  directly in `index.html` instead, so it stays crisp at any size; the PNGs
  are for `<link rel="icon">` / social preview only.

## Content guardrails (from the app repo's `docs/v1-scope.md`)

Copy on this page was written to match what's actually true of Roomie v1 —
check `roomie/docs/v1-scope.md` and
`roomie/.claude/agent-memory/marketing-specialist/v1_scope_facts.md` before
changing claims:

- Listing is free, always. An optional paid **boost** exists but **pricing
  is not finalized — don't publish a number.**
- Never promise a boost gets more calls or a faster rental — only that it
  buys placement.
- Android only, Beer Sheva only, for now.
- No in-app chat — calling is the only contact method.
- No verification badge, no account required to browse.
- Location is on-device only; phone numbers are shown the same way a
  printed flyer would show them (not "collected").
- Legal: only `privacy-policy` is published at
  `noamav710.github.io/roomie-legal/` — there's no terms-of-service page
  yet, so the footer doesn't link one.

## Known gaps

- Hero graphic is an original SVG mockup (abstract listing cards), not a
  real product screenshot — the app UI wasn't available to screenshot from
  this session.
- OG image reuses `assets/icon.png` (square) instead of a proper 1200×630
  social-share image — `docs/v1-scope.md` section D still lists that as
  open.
- Play Store hi-res icon / feature graphic are Play Console assets, not
  files in this repo — also still open per the same doc.
