# Wiring the hero video into index.html

**Do not apply until `assets/videos/hero.mp4` actually exists.** Until then the
SVG map hero stays, and the page has no broken reference.

Every item here fixes a specific finding from the review that killed the first
hero video.

## 1. CSS — replace the `.hero-art svg` rule (index.html ~line 124)

Keep the existing `.hero-art svg` rule; add below it:

```css
  .hero-video-wrap { position: relative; width: 100%; height: 100%;
    display: flex; align-items: center; justify-content: center; }
  /* Contained, not covered: the file is 9:20 and the stage is 4:5, so
     object-fit:cover would throw away well over half the frame. Height-first
     sizing keeps the whole phone screen visible at every stage width. */
  .hero-video { height: 100%; width: auto; max-width: 100%; display: block;
    border-radius: 22px; background: var(--mint);
    box-shadow: 0 14px 34px rgba(8,63,73,.22); }
  .hero-video-toggle {
    position: absolute; right: 6px; bottom: 6px; z-index: 2;
    width: 40px; height: 40px; border-radius: 50%; border: 0; cursor: pointer;
    background: rgba(8,63,73,.72); color: var(--paper);
    display: grid; place-items: center; font-size: 15px; line-height: 1;
  }
  .hero-video-toggle:focus-visible { outline: 3px solid var(--coral); outline-offset: 2px; }
  @media (prefers-reduced-motion: reduce) {
    .hero-video-toggle { display: none; }
  }
```

Note the inner radius is an explicit `22px`, **not** `border-radius: inherit`.
The stage is 32px with a 7px border, and the video sits inside 30px of padding,
so `inherit` gave it a radius far too large for its position and the corners
could not read as concentric.

## 2. Markup — replace the `<svg viewBox="0 0 360 380">…</svg>` block inside `.stage`

```html
          <div class="hero-video-wrap">
            <video id="hero-video" class="hero-video"
                   autoplay muted loop playsinline preload="metadata"
                   poster="assets/videos/hero-poster.jpg"
                   aria-label="Roomie: rooms on a map, a compatibility score, and the lister's phone number">
              <source src="assets/videos/hero.webm" type="video/webm">
              <source src="assets/videos/hero.mp4" type="video/mp4">
            </video>
            <button class="hero-video-toggle" id="hero-video-toggle"
                    type="button" aria-label="Pause video">&#10073;&#10073;</button>
          </div>
```

Two deliberate choices:

- **No `aria-hidden`.** The first version hid the video from assistive tech
  while it carried the entire product story. It gets a real label instead.
- **WebM first.** Browsers take the first source they can play; VP9 is smaller
  than the H.264 fallback.

## 3. Script — add before `</body>`

```html
<script>
  (function () {
    var v = document.getElementById('hero-video');
    var b = document.getElementById('hero-video-toggle');
    if (!v || !b) return;

    // WCAG 2.2.2: anything that autoplays and moves for more than 5 seconds
    // needs a way to stop it. The loop is ~10.7s.
    function sync() {
      var paused = v.paused;
      b.innerHTML = paused ? '&#9654;' : '&#10073;&#10073;';
      b.setAttribute('aria-label', paused ? 'Play video' : 'Pause video');
    }
    b.addEventListener('click', function () {
      if (v.paused) { v.play(); } else { v.pause(); }
      sync();
    });
    v.addEventListener('play', sync);
    v.addEventListener('pause', sync);

    // Respect the OS setting: hold the poster frame instead of playing.
    var mq = window.matchMedia('(prefers-reduced-motion: reduce)');
    function applyMotion() {
      if (mq.matches) { v.removeAttribute('autoplay'); v.pause(); }
    }
    mq.addEventListener ? mq.addEventListener('change', applyMotion)
                        : mq.addListener(applyMotion);
    applyMotion();
    sync();
  })();
</script>
```

The poster is deliberately a frame from the **app** section, not the intro —
a reduced-motion user sees a still forever, and it must show them the product,
not three seconds of the problem.

## 4. Stop ignoring the video

`.gitignore` currently ignores all of `assets/videos/` — that was to keep the
rejected AI video out. Replace that rule with the specific dead files, or drop
it once they are gone, then commit the new `hero.mp4`, `hero.webm` and
`hero-poster.jpg`.

## 5. README

The "Known gaps" section still describes the hero as the SVG map mockup and
records the rejected video. Update both bullets.

## 6. Check before pushing

- Desktop and ~390px wide: the video is fully visible, never cropped, and the
  page body does not scroll sideways.
- DevTools Network: `hero.webm` served, no 404 for the mp4 or the poster.
- Click the pause button; press Tab to it and hit Enter.
- Toggle reduced motion (DevTools → Rendering → Emulate CSS
  `prefers-reduced-motion`) and reload: the poster holds, nothing moves.
