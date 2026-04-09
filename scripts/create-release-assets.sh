#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"

mkdir -p "$DIST_DIR"

echo "Building DMG..." >&2
bash "$ROOT_DIR/scripts/create-dmg.sh" >/dev/null

echo "Building ZIP..." >&2
bash "$ROOT_DIR/scripts/create-zip.sh" >/dev/null

echo "Writing checksums..." >&2
cd "$DIST_DIR"
shasum -a 256 Entule.dmg Entule.zip > SHA256SUMS.txt

echo "$DIST_DIR/Entule.dmg"
echo "$DIST_DIR/Entule.zip"
echo "$DIST_DIR/SHA256SUMS.txt"
