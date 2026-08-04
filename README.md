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
- **No search and no filters.** v1 has neither; the app has no list UI at all,
  only the map. "Filter by price and move-in date" was live on this page and was
  false. Don't reintroduce it, and don't use a magnifying-glass icon.
- **Compatibility is person-to-person.** `src/app/(tabs)/explore.tsx` is the
  "Roommates" tab — "People looking to share a place" — and scores you against
  other *users*. `src/components/property-details.tsx` has no match score and no
  resident profiles. Say "how well you match the people looking to share a
  place"; **never** "the people already living there." (The Play Store listing
  still has this wrong — fix before submission.)
- **The no-account claim splits.** `firestore.rules` is `allow read: if true`
  on `apartments` but `signedIn()` on `users` and `endorsements`. So: map,
  listings and phone numbers are open signed-out; profiles, match scores and
  endorsements need a free account. Don't flatten this into "no account needed."
- **Boost = placement only.** It may say a boost gives a distinct map pin, a
  Boosted badge, and a set number of days. Never a faster rental, more calls, or
  any outcome — that distinction is going into the Terms. Never "top of the
  list": there is no list. No price on the page; the packages are unvalidated.
- Don't mention the dormant early-bird token system, house rules, move-in dates,
  a star average on profiles, or a step count for the listing form.
- No verification badge — the component exists but is hidden for v1.
- Location is on-device only; phone numbers are shown the way a printed flyer
  would show them (not "collected").

## The waitlist form

Posts to Formspree (`formspree.io/f/mkodlarw`), wired and verified 2026-08-02 —
real submissions return `{"ok":true}` and the mail arrives. It submits by
`fetch` so the visitor stays on the page; a bare Formspree POST would redirect
them to a Formspree-branded thank-you page.

- The ID lives in **two places that must stay in sync**: the `FORMSPREE_ID`
  constant at the top of the inline script, and the form's `action` attribute,
  which is the no-JavaScript fallback.
- A visible seeker/lister radio records which kind of signup it is. Arriving via
  the boost CTA preselects the lister option. The launch plan is supply-first,
  so the lister half of the list is the valuable one.
- `_gotcha` is a honeypot — an off-screen text input, deliberately not
  `type="hidden"`, which bots skip. Formspree silently drops anything that fills
  it.
- **Gotcha:** `.waitlist-form` sets `display: flex`, which beats the `hidden`
  attribute's `display: none`. Hiding the form on success needs the explicit
  `.waitlist-form[hidden]` rule — without it the confirmation appears *and* the
  form stays on screen, looking like the submission failed.
- The radio labels need their `:focus-visible` ring: the real input is visually
  hidden, so without it the control is unusable by keyboard. Test with real Tab
  and Arrow key presses — programmatic `.focus()` does not reliably trigger
  `:focus-visible`, and will look like a false failure.

## Known gaps

- Hero graphic is an original SVG mockup — a map with rent pins — not a real
  product screenshot. It must stay a *map*: v1 has no list UI, and the previous
  art depicted a scrollable results list, which the app cannot show.
- An AI-generated hero video was tried and rejected. It reproduced Facebook,
  WhatsApp and Yad2 branding, carried a generative-AI watermark on every frame,
  showed a listing *list*, and closed on a landlord chat thread — the exact
  thing the hero copy says Roomie removes. The file is kept at `assets/videos/`
  and gitignored. Any replacement must stay a map, show rent on pins and a real
  phone call, and contain no third-party logos.
- Play Store hi-res icon / feature graphic are Play Console assets, not files
  here. Swap the "Get notified at launch" CTA for a Play Store link once the
  listing is public.
- Formspree is a form-to-email relay, not a list manager, and there is no double
  opt-in. If the waitlist grows past a few dozen, move to Mailchimp or
  Buttondown. Signups live only in Formspree and the notification emails —
  nothing durable on our side.
- The boost section says it "isn't on sale yet", which stays true until *both*
  the boost terms are published (draft on branch `boost-terms-draft` in
  roomie-legal, awaiting the lawyer) and the PayPal webhook ships.

Closed recently: the dead `mailto:` form, the unlinked terms and
account-deletion pages, and the square OG image (now a real 1200×630).

## Older draft

An earlier bilingual Hebrew/English version — Heebo font, separate `styles.css`
/ `script.js`, RTL toggle, "compatibility score" positioning — was superseded by
the current single-file English rewrite. It lives on the local branch
`local-bilingual-version`, never pushed, so it exists only on the machine that
created it.
