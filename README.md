# roomie-landing

Static marketing/waitlist page for Roomie — Beer Sheva student housing.
**Live at https://roomie.co.il.** No build step: `index.html` is self-contained
(plain CSS, Google Fonts CDN for type). Open it in a browser to work on it;
commit to `main` and push to publish.

`assets/` holds logo exports copied from `roomie/assets/images/`, used only for
`<link rel="icon">` and social preview. The nav/footer brand mark is inlined as
SVG in `index.html` so it stays crisp at any size — defined once as a `<g
id="roomie-mark">` in a hidden `<svg>` near the top of `<body>`, then referenced
by `<use>` in the header and footer. Edit it in one place.

Draw the mark with paths, never `<text>`. An earlier version set the "R" as an
SVG `<text>` in DejaVu Sans, which almost nobody has installed, so it silently
fell back to Arial and the logo rendered differently on every machine.

## Deploying

GitHub Pages, **Source: "Deploy from a branch"**, branch `main`, folder `/ (root)`.

Keep it on branch deploy. Switched to "GitHub Actions", Pages waits for a
workflow to publish an artifact — this repo has none, so every URL 404s with no
error shown in the Pages UI. That is what kept the site down after the first
push. When the site 404s, check this before touching DNS or re-pushing:

```
gh api repos/noamav710/roomie-landing/pages        # build_type must be "legacy", status "built"
gh api repos/noamav710/roomie-landing/pages/builds # empty array = nothing ever deployed
gh api -X POST repos/noamav710/roomie-landing/pages/builds  # force a rebuild
```

## Domains

**Apex `roomie.co.il` is canonical; `www` redirects to it.** The `CNAME` file
sets this and overrides the Pages settings UI — to switch to `www`, edit `CNAME`,
not the UI. `index.html` matches the apex in `<link rel="canonical">` and `og:url`.

DNS at the registrar: four `A` records on `@` → `185.199.108.153`,
`185.199.109.153`, `185.199.110.153`, `185.199.111.153`, plus a `CNAME` on `www`
→ `noamav710.github.io`. The A records serve the canonical apex; the `www` CNAME
just gets those visitors redirected. GitHub rotates those IPs occasionally —
Settings → Pages warns if they go stale. HTTPS is enforced, certificate covers
both hostnames.

## Content guardrails (from the app repo's `docs/v1-scope.md`)

Copy here matches what's true of Roomie v1. Check `roomie/docs/v1-scope.md` and
`roomie/.claude/agent-memory/marketing-specialist/v1_scope_facts.md` before
changing claims:

- Listing is free, always. An optional paid **boost** exists but **pricing is
  not finalized — don't publish a number.**
- Never promise a boost gets more calls or a faster rental — only placement.
- Android only. The product really is one city (Beer Sheva) at v1 — but
  **keep page copy city-agnostic.** Headline, features, listers, trust and
  waitlist sections are deliberately written without a city or campus name so
  expanding doesn't mean rewriting the page. Exactly one line names the launch
  city, the hero note: "Android first. Starting in Beer Sheva." Say "starting
  in", never "only" — `v1-scope.md` plans a second city once the first works.
- No in-app chat — calling is the only contact method.
- No verification badge, no account required to browse.
- Location is on-device only; phone numbers are shown the way a printed flyer
  would show them (not "collected").

## Known gaps

- **The waitlist form doesn't reliably work.** Browsers block or mishandle
  `mailto:` form POSTs, and it's the page's only signup path. Swap for Formspree
  or similar before driving traffic here.
- **Terms and account-deletion pages are live but unlinked.** `roomie-legal`
  serves `/terms-of-use` and `/account-deletion` alongside `/privacy-policy`;
  the footer links only the last. Google Play requires a reachable
  account-deletion URL.
- OG image reuses `assets/icon.png` (1024×1024) instead of ~1200×630, so link
  previews crop it.
- Hero graphic is an original SVG mockup, not a real product screenshot.
- Play Store hi-res icon / feature graphic are Play Console assets, not files
  here. Swap the "Get notified at launch" CTA for a Play Store link once the
  listing is public.

## Older draft

An earlier bilingual Hebrew/English version — Heebo font, separate `styles.css`
/ `script.js`, RTL toggle, "compatibility score" positioning — was superseded by
the current single-file English rewrite. It lives on the local branch
`local-bilingual-version`, never pushed, so it exists only on the machine that
created it.
