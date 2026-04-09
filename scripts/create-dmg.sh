#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
STAGE_DIR="$DIST_DIR/dmg-stage"
APP_DIR="$("$ROOT_DIR/scripts/build-local-app.sh" "$DIST_DIR/Entule.app")"
RW_DMG_PATH="$DIST_DIR/Entule-temp.dmg"
DMG_PATH="$DIST_DIR/Entule.dmg"
VOLUME_NAME="Entule"
MOUNT_POINT="/Volumes/$VOLUME_NAME"

rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR"
rm -f "$RW_DMG_PATH"
rm -f "$DMG_PATH"

ditto "$APP_DIR" "$STAGE_DIR/Entule.app"
ln -s /Applications "$STAGE_DIR/Applications"

# Build a writable DMG first so we can apply a polished Finder layout.
hdiutil create \
  -volname "$VOLUME_NAME" \
  -srcfolder "$STAGE_DIR" \
  -ov \
  -format UDRW \
  "$RW_DMG_PATH" >&2

DEVICE="$(hdiutil attach -readwrite -noverify -noautoopen "$RW_DMG_PATH" | awk '/^\/dev\// {print $1; exit}')"

# Finder layout polish for drag-to-Applications screen.
# This may fail in headless CI; keep release flow resilient.
if [[ -n "${DEVICE:-}" ]]; then
  if [[ "${CI:-}" != "true" ]]; then
    python3 - "$VOLUME_NAME" <<'PY'
import subprocess
import sys

volume = sys.argv[1]
script = f'''
tell application "Finder"
  tell disk "{volume}"
    open
    delay 0.4
    set current view of container window to icon view
    set toolbar visible of container window to false
    set statusbar visible of container window to false
    set sidebar width of container window to 0
    set bounds of container window to {{120, 120, 760, 520}}
    set opts to the icon view options of container window
    set arrangement of opts to not arranged
    set icon size of opts to 128
    set text size of opts to 14
    set position of item "Entule.app" of container window to {{180, 230}}
    set position of item "Applications" of container window to {{500, 230}}
    update without registering applications
    close
  end tell
end tell
'''

try:
    subprocess.run(
        ["osascript", "-e", script],
        check=False,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        timeout=8,
    )
except subprocess.TimeoutExpired:
    pass
PY
  fi

  # Make sure metadata is flushed before conversion.
  sync
  hdiutil detach "$DEVICE" -force >/dev/null || true
fi

hdiutil convert "$RW_DMG_PATH" -format UDZO -imagekey zlib-level=9 -o "$DMG_PATH" >&2

rm -rf "$STAGE_DIR"
rm -f "$RW_DMG_PATH"
echo "$DMG_PATH"
