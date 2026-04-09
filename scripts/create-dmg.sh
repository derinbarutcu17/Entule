#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$ROOT_DIR/Info.plist")"
DIST_DIR="$ROOT_DIR/dist"
STAGE_DIR="$DIST_DIR/dmg-stage"
APP_DIR="$("$ROOT_DIR/scripts/build-local-app.sh" "$DIST_DIR/Entule.app")"
DMG_PATH="$DIST_DIR/Entule.dmg"

rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR"
rm -f "$DMG_PATH"

ditto "$APP_DIR" "$STAGE_DIR/Entule.app"
ln -s /Applications "$STAGE_DIR/Applications"

hdiutil create \
  -volname "Entule" \
  -srcfolder "$STAGE_DIR" \
  -ov \
  -format UDZO \
  "$DMG_PATH" >&2

rm -rf "$STAGE_DIR"
echo "$DMG_PATH"
