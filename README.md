# roomie-landing

Static marketing/waitlist page for Roomie — Beer Sheva student housing.
**Live at https://roomie.co.il.** No build step: `index.html` is self-contained
(Tailwind-free, plain CSS, Google Fonts CDN for type). To work on it, open
`index.html` in a browser; to publish, commit to `main` and push.

## What's here

- `index.html` — the page. Hero, "how it works", lister pitch, trust
  section, waitlist email capture (currently a `mailto:` form — there's no
  backend yet, so submissions open the visitor's email client addressed to
  `noam123av@gmail.com`).
- `assets/` — logo exports copied from `roomie/assets/images/` (icon,
  favicon, tab-bar mark). The nav/footer brand mark is inlined as SVG
  directly in `index.html` instead, so it stays crisp at any size; the PNGs
  are for `<link rel="icon">` / social preview only.

## How it deploys

GitHub Pages, **Source: "Deploy from a branch"**, branch `main`, folder
`/ (root)`.

That setting matters more than it looks. If Pages is switched to **"GitHub
Actions"** as the build source, it waits for a workflow to publish an artifact —
and since this repo has no workflow file, nothing ever deploys and every URL
returns 404, with no error surfaced anywhere in the Pages UI. That is exactly
why the site sat dead after the first push. If the site 404s, check this
*before* touching DNS or re-pushing files:

```
gh api repos/noamav710/roomie-landing/pages
```

`"build_type"` must be `"legacy"` (the API's name for branch deploys) and
`"status"` should be `"built"`. `gh api repos/noamav710/roomie-landing/pages/builds`
lists past builds — an empty array means nothing has ever deployed. Force a
rebuild with:

```
gh api -X POST repos/noamav710/roomie-landing/pages/builds
```

## Domains

**The apex `roomie.co.il` is canonical; `www` redirects to it.** This is driven
by the `CNAME` file in this repo, whose contents override whatever custom domain
is typed into the Pages settings UI — so if you ever want `www` to be canonical
instead, edit `CNAME`; changing it only in the GitHub UI won't stick.
`index.html` agrees with the apex in both `<link rel="canonical">` and `og:url`.

DNS records at the registrar for `roomie.co.il`:

| Type | Host/Name | Value |
|---|---|---|
| A | `@` (apex/root) | `185.199.108.153` |
| A | `@` (apex/root) | `185.199.109.153` |
| A | `@` (apex/root) | `185.199.110.153` |
| A | `@` (apex/root) | `185.199.111.153` |
| CNAME | `www` | `noamav710.github.io` |

The four `A` records serve the canonical apex; the `www` CNAME exists so people
who type `www` still land somewhere and get redirected. GitHub does occasionally
rotate those IPs — Settings → Pages shows a "DNS check" warning if they go
stale. HTTPS is enforced and the certificate covers both hostnames.

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

## Known gaps

- **The waitlist form doesn't reliably work.** Chrome and most modern browsers
  block or unpredictably handle `mailto:` form POSTs. It's the only signup path
  on the page, so this is closer to broken than to a stopgap — worth swapping
  for Formspree, Mailchimp, or similar before driving any traffic here.
- **Two legal pages are live but unlinked.** `roomie-legal` now publishes
  `/terms-of-use` and `/account-deletion` in addition to `/privacy-policy` — all
  three return 200. The footer still links only the privacy policy. Google Play
  requires a reachable account-deletion URL, so linking these is worth doing
  before the store listing goes up. (Earlier versions of this file said the
  other two didn't exist yet; that is out of date.)
- Hero graphic is an original SVG mockup (abstract listing cards), not a
  real product screenshot — the app UI wasn't available to screenshot from
  the session that built this.
- OG image reuses `assets/icon.png`, which is 1024×1024, instead of a proper
  1200×630 social-share image — link previews will crop it or render it small.
  `docs/v1-scope.md` section D still lists that as open.
- Play Store hi-res icon / feature graphic are Play Console assets, not
  files in this repo — also still open per the same doc.
- Once the Play listing is public, swap the "Get notified at launch" CTA for a
  direct Play Store link.

## Older draft

An earlier bilingual Hebrew/English version of this page — Heebo font, separate
`styles.css` / `script.js`, an RTL language toggle, and "compatibility score"
positioning — was superseded by the current single-file English rewrite. It is
preserved on the local branch `local-bilingual-version`, which was never pushed,
so it exists only on the machine that created it.
