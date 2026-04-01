# Entule

Entule is a lightweight macOS app for saving a work checkpoint and reopening it later.

## What It Does

- Saves a checkpoint made of apps, folders, files, and URLs
- Reopens the latest checkpoint with one action
- Lets you create presets for repeatable work setups
- Runs from the menu bar and opens into a dedicated app window

## Download

For now, Entule is distributed directly from this repository.

- Open the latest release assets when available
- Or build the app locally from source

## Build Locally

```bash
swift build
./scripts/install-local-app.sh
```

That installs `Entule.app` into `/Applications`.

## Create A Local DMG

```bash
./scripts/create-dmg.sh
```

The generated disk image will appear in:

`dist/Entule-v0.1.0.dmg`

## Requirements

- macOS 13 or later
- Automation permission for Finder, Safari, and Google Chrome if you want browser or Finder detection

## Privacy

Entule stores its data locally on your Mac:

`~/Library/Application Support/Entule/state.json`

No cloud sync or remote storage is used in v1.

## Notes

- Browser and Finder detection are best effort
- Entule reopens saved resources, but it does not restore exact internal app state
- Some third-party apps may behave differently depending on how they handle macOS launch requests
