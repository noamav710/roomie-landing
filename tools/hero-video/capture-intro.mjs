/* Renders problem-intro.html to a numbered JPEG sequence.
 *
 * Frame-stepped on purpose: the page exposes __render(t) and we screenshot
 * each exact t rather than letting Playwright record video. Recording drops
 * frames under load and drifts, which shows up as stutter once the result is
 * concatenated with real 30fps footage.
 *
 *   node capture-intro.mjs [outDir] [fps]
 */
import { chromium } from 'playwright';
import { mkdir, rm } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { dirname, join, resolve } from 'node:path';

const here = dirname(fileURLToPath(import.meta.url));
const outDir = resolve(process.argv[2] ?? join(here, 'frames'));
const fps = Number(process.argv[3] ?? 30);

const W = 1080, H = 2400;

await rm(outDir, { recursive: true, force: true });
await mkdir(outDir, { recursive: true });

const browser = await chromium.launch();
const page = await browser.newPage({
  viewport: { width: W, height: H },
  deviceScaleFactor: 1,
});

await page.goto('file://' + join(here, 'problem-intro.html').replace(/\\/g, '/'));

// Fonts must be settled before the first measure(), or bubble heights are
// computed against the fallback face and the whole stack shifts mid-render.
await page.waitForFunction(() => window.__ready !== undefined);
await page.evaluate(() => window.__ready);

const duration = await page.evaluate(() => window.__duration);
const total = Math.round(duration * fps);

process.stdout.write(`rendering ${total} frames @ ${fps}fps (${duration}s)\n`);

for (let i = 0; i < total; i++) {
  const t = i / fps;
  await page.evaluate((tt) => window.__render(tt), t);
  await page.screenshot({
    path: join(outDir, `f${String(i).padStart(5, '0')}.jpg`),
    type: 'jpeg',
    quality: 92,
  });
  if (i % 30 === 0) process.stdout.write(`  ${i}/${total}\n`);
}

await browser.close();
process.stdout.write(`done -> ${outDir}\n`);
