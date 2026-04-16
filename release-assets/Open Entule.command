#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_PATH="$SCRIPT_DIR/Entule.app"

if [ ! -d "$APP_PATH" ]; then
  APP_PATH="/Applications/Entule.app"
fi

xattr -cr "$APP_PATH" || true
open "$APP_PATH"
