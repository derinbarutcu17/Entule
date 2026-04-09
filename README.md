# Entule

Entule is a macOS app for saving a work checkpoint and reopening it later.

## Fastest way to get it

- DMG download (recommended): https://github.com/derinbarutcu17/Entule/releases/latest/download/Entule.dmg
- ZIP fallback: https://github.com/derinbarutcu17/Entule/releases/latest/download/Entule.zip
- Terminal (DMG, fails fast on broken links): `curl -fL --retry 3 -o ~/Downloads/Entule.dmg https://github.com/derinbarutcu17/Entule/releases/latest/download/Entule.dmg && open ~/Downloads/Entule.dmg`
- Terminal (ZIP fallback): `curl -fL --retry 3 -o ~/Downloads/Entule.zip https://github.com/derinbarutcu17/Entule/releases/latest/download/Entule.zip && open ~/Downloads/Entule.zip`

## Use

1. Open the DMG (or ZIP)
2. Drag Entule to Applications
3. Launch Entule
4. Save a session or resume your last one

## Build from source

```bash
swift build
./scripts/install-local-app.sh
bash ./scripts/create-dmg.sh
bash ./scripts/create-zip.sh
```

## Troubleshooting downloads

- If a download is tiny (for example a few KB), it is usually a failed link HTML page, not the app file.
- Use the `curl -fL` commands above so failures stop immediately.
- Confirm file size after download:
  - DMG should be around a few MB, not KB.
  - ZIP should also be around a few MB.
- If macOS says “Apple could not verify Entule is free of malware” on first launch:
  - `bash ./scripts/unblock-downloaded-app.sh /Applications/Entule.app`
  - Then launch Entule again.

## Notes

- saves apps, files, folders, URLs, notes, and optional Shortcut names
- keeps data local on your Mac
- does not restore exact in-app state or window layouts
- some apps need macOS Automation permission
