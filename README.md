# Entule

Entule is a macOS app for saving a work checkpoint and reopening it later.

## Download

One click:

[Download the latest Entule DMG](https://github.com/derinbarutcu17/Entule/releases/latest/download/Entule.dmg)

Terminal:

```bash
curl -L -o ~/Downloads/Entule.dmg https://github.com/derinbarutcu17/Entule/releases/latest/download/Entule.dmg && open ~/Downloads/Entule.dmg
```

## Use

1. Open the DMG
2. Drag Entule to Applications
3. Launch Entule
4. Save a session or resume your last one

## What it does

- saves apps, files, folders, URLs, notes, and optional Shortcut names
- reopens saved items later
- keeps data local on your Mac
- uses a menu bar app plus a main window

## What it does not do

- it does not restore exact in-app state
- it does not restore window or monitor layouts
- some apps need macOS Automation permission

## Local data

Entule stores data here:

```text
~/Library/Application Support/Entule/state.json
```

## Build from source

```bash
swift build
./scripts/install-local-app.sh
./scripts/create-dmg.sh
```

## Release notes

The GitHub Action builds `dist/Entule.dmg` and publishes it as the release asset, so the download link above stays stable once a release is published.

