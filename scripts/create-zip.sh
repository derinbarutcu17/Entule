#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
APP_DIR="$("$ROOT_DIR/scripts/build-local-app.sh" "$DIST_DIR/Entule.app")"
ZIP_PATH="$DIST_DIR/Entule.zip"

rm -f "$ZIP_PATH"

# Create a simple zip that macOS can unpack without the DMG/Gatekeeper path.
ditto -c -k --sequesterRsrc --keepParent "$APP_DIR" "$ZIP_PATH" >&2

echo "$ZIP_PATH"
