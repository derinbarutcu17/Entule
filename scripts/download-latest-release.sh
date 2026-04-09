#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REPO="derinbarutcu17/Entule"
DOWNLOAD_DIR="${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"
TMP_JSON="$(mktemp)"
TMP_DMG="${DOWNLOAD_DIR}/Entule-latest.dmg"

cleanup() {
  rm -f "$TMP_JSON"
}
trap cleanup EXIT

curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" -o "$TMP_JSON"
ASSET_URL="$(python3 - <<'PY' "$TMP_JSON"
import json, sys
path = sys.argv[1]
with open(path) as f:
    data = json.load(f)
for asset in data.get('assets', []):
    name = asset.get('name', '')
    if name.endswith('.dmg'):
        print(asset['browser_download_url'])
        raise SystemExit(0)
raise SystemExit('No .dmg asset found in the latest release')
PY
)"

curl -fL "$ASSET_URL" -o "$TMP_DMG"
open "$TMP_DMG"

echo "$TMP_DMG"