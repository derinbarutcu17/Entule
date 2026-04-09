# Entule

Entule is a macOS app for saving a work checkpoint and reopening it later.

## Fastest way to get it

- Download: https://github.com/derinbarutcu17/Entule/releases/latest/download/Entule.dmg
- Site: https://derinbarutcu17.github.io/Entule/

## Use

1. Open the DMG
2. Drag Entule to Applications
3. Launch Entule
4. Save a session or resume your last one

## Build from source

```bash
swift build
./scripts/install-local-app.sh
./scripts/create-dmg.sh
```

## Notes

- saves apps, files, folders, URLs, notes, and optional Shortcut names
- keeps data local on your Mac
- does not restore exact in-app state or window layouts
- some apps need macOS Automation permission

