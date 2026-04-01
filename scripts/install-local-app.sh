#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TARGET_APP="/Applications/Entule.app"
APP_DIR="$("$ROOT_DIR/scripts/build-local-app.sh" "$ROOT_DIR/.build/local-app/Entule.app")"

pkill -x Entule 2>/dev/null || true
rm -rf "$TARGET_APP"
ditto "$APP_DIR" "$TARGET_APP"
codesign --verify --deep --strict "$TARGET_APP" >&2

echo "$TARGET_APP"
