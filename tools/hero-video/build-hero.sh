#!/usr/bin/env bash
# Builds the landing page hero video.
#
#   ./build-hero.sh <app-recording.mp4> [start] [duration]
#
#     start     seconds into the recording where the map shot begins (default 0)
#     duration  seconds of app footage to keep (default 7.0)
#
# Output lands in ../../assets/videos/ as hero.mp4, hero.webm, hero-poster.jpg.
#
# Structure: 3.7s problem intro (rendered from problem-intro.html) + app
# footage. Silent, loops.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Override when testing the pipeline with stand-in footage, so a dry run
# cannot clobber the real asset. It has happened.
OUT="${OUT_DIR:-$HERE/../../assets/videos}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

REC="${1:?usage: build-hero.sh <app-recording.mp4> [start] [duration]}"
START="${2:-0}"
DUR="${3:-7.0}"

# 540x1200 keeps the 9:20 shape. The stage renders it around 230px wide, so
# this is still ~2x for retina while keeping the file small.
W=540; H=1200; FPS=30

echo "==> rendering problem intro"
node "$HERE/capture-intro.mjs" "$TMP/frames" "$FPS"

echo "==> encoding intro"
ffmpeg -v error -y -framerate "$FPS" -i "$TMP/frames/f%05d.jpg" \
  -vf "scale=$W:$H:flags=lanczos,format=yuv420p" \
  -c:v libx264 -preset slow -crf 20 "$TMP/intro.mp4"

echo "==> trimming app footage (start=${START}s duration=${DUR}s)"
# -ss before -i seeks fast; re-encoding anyway so frame accuracy is fine.
# force_original_aspect_ratio + pad tolerates a recording that is not exactly
# 9:20 rather than silently stretching faces and text.
ffmpeg -v error -y -ss "$START" -t "$DUR" -i "$REC" \
  -vf "scale=$W:$H:force_original_aspect_ratio=decrease,pad=$W:$H:(ow-iw)/2:(oh-ih)/2:color=0xd8eee5,fps=$FPS,format=yuv420p" \
  -an -c:v libx264 -preset slow -crf 20 "$TMP/app.mp4"

echo "==> concatenating"
ffmpeg -v error -y -i "$TMP/intro.mp4" -i "$TMP/app.mp4" \
  -filter_complex "[0:v][1:v]concat=n=2:v=1:a=0[v]" -map "[v]" \
  -c:v libx264 -preset slow -crf 20 -pix_fmt yuv420p "$TMP/full.mp4"

mkdir -p "$OUT"

echo "==> mp4"
ffmpeg -v error -y -i "$TMP/full.mp4" \
  -c:v libx264 -preset slow -crf 26 -pix_fmt yuv420p -an -movflags +faststart \
  "$OUT/hero.mp4"

echo "==> webm"
ffmpeg -v error -y -i "$TMP/full.mp4" \
  -c:v libvpx-vp9 -crf 36 -b:v 0 -row-mt 1 -an "$OUT/hero.webm"

# The poster is what shows before playback AND what prefers-reduced-motion
# users see permanently. It must therefore be the product, never the intro:
# a still of the chaos would leave those users having seen the problem and
# never the solution. Default lands ~2.5s into the app section.
POSTER_AT=$(awk -v d=3.7 'BEGIN{printf "%.2f", d + 2.5}')
echo "==> poster at ${POSTER_AT}s (inside the app section, never the intro)"
ffmpeg -v error -y -ss "$POSTER_AT" -i "$TMP/full.mp4" -frames:v 1 -q:v 3 \
  "$OUT/hero-poster.jpg"

echo
echo "done:"
for f in hero.mp4 hero.webm hero-poster.jpg; do
  printf "  %-18s %8s bytes\n" "$f" "$(stat -c%s "$OUT/$f")"
done
ffprobe -v error -show_entries format=duration -show_entries stream=width,height \
  -of default=noprint_wrappers=1 "$OUT/hero.mp4"
