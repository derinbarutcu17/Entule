#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="/Applications/Entule.app"

if [[ ! -d "$APP_DIR" ]]; then
  APP_DIR="$("$ROOT_DIR/scripts/install-local-app.sh")"
fi

pkill -x Entule 2>/dev/null || true
open -na "$APP_DIR"

echo "Opened $APP_DIR"
