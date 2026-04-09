#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"

mkdir -p "$DIST_DIR"

echo "Building DMG..." >&2
bash "$ROOT_DIR/scripts/create-dmg.sh" >/dev/null

echo "$DIST_DIR/Entule.dmg"
