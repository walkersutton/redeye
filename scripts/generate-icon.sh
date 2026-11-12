#!/bin/bash
# Regenerate AppIcon PNGs from scripts/AppIcon.svg. Requires: brew install librsvg
set -euo pipefail
cd "$(dirname "$0")/.."

SVG=scripts/AppIcon.svg
OUT=redeye/Assets.xcassets/AppIcon.appiconset

for size in 16 32 64 128 256 512 1024; do
	rsvg-convert -w "$size" -h "$size" "$SVG" -o "$OUT/icon_${size}x${size}.png"
done
echo "Wrote AppIcon PNGs to $OUT"
