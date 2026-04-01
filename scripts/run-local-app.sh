#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$("$ROOT_DIR/scripts/build-local-app.sh" "$ROOT_DIR/.build/local-app/Entule.app")"

pkill -x Entule 2>/dev/null || true
open -na "$APP_DIR"

echo "Opened $APP_DIR"
