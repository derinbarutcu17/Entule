#!/bin/zsh
set -euo pipefail

APP_PATH="${1:-/Applications/Entule.app}"

if [[ ! -d "$APP_PATH" ]]; then
  echo "App not found at: $APP_PATH" >&2
  exit 1
fi

# Clear macOS quarantine flag from downloaded app bundle.
xattr -dr com.apple.quarantine "$APP_PATH" 2>/dev/null || true

echo "Unblocked: $APP_PATH"
echo "Launching..."
open -na "$APP_PATH"
