# Hero video build

Builds the landing page hero: a ~10.7s silent loop, **problem → solution**.

| section | length | source |
|---|---|---|
| the problem — 23:47, messages piling up, "Still no room." | 3.7s | `problem-intro.html`, rendered here |
| the solution — map → pin → match → call | ~7s | screen recording of the real app |

Full context, including the demo data and the shot list, is in the app repo at
`docs/demo-recording.md`.

## Build

```bash
npm install                       # once
./build-hero.sh /path/to/recording.mp4 [start] [duration]
```

`start` and `duration` pick the segment of the recording to keep, in seconds.
Output goes to `../../assets/videos/` as `hero.mp4`, `hero.webm` and
`hero-poster.jpg`.

To test the pipeline without touching the real asset:

```bash
OUT_DIR=/tmp/dryrun ./build-hero.sh some-clip.mp4
```

Then follow `APPLY-TO-INDEX.md` to wire it into the page.

## Why the intro is frame-stepped

`capture-intro.mjs` calls `window.__render(t)` for each exact `t` and
screenshots, rather than using Playwright's video recording. Recording drops
frames under load and drifts; the result here is byte-identical on every run,
which matters because it is concatenated with real footage at a fixed frame
rate.

`problem-intro.html` therefore contains no CSS animations and no
`requestAnimationFrame` — every visual property is a pure function of `t`.

## Rules the intro must keep

The first attempt at this video was thrown away for reproducing Facebook,
WhatsApp and Yad2 branding, carrying a generative-AI watermark on every frame,
and closing on a landlord chat thread — the exact thing the hero copy promises
Roomie removes.

- **No logos, no imitated client UI.** Bubbles are plain rounded rectangles in
  the brand's own teal/ink palette — deliberately not WhatsApp green or
  Messenger blue.
- **Naming a competitor in words is fine; reproducing their marks is not.**
  Nominative fair use covers "Facebook groups" as text. It does not cover
  drawing their logo.
- **Nothing the app cannot do.** No chat UI, and no list of results — v1 is a
  map.
- Shekels, never dollars.

## Sizing

Rendered at 1080x2400 to match the emulator exactly, so the intro concatenates
with the recording without rescaling, then both are encoded down to 540x1200.
The stage renders it around 230px wide, so that is still roughly 2x for retina.

The file is 9:20 and the hero stage is 4:5. The video is **contained** by the
CSS, never `object-fit: cover` — covering would discard more than half the
frame, which is what went wrong the first time.
