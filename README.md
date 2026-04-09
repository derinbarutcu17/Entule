# Entule

Entule is a macOS app that helps you save a work checkpoint and reopen it later.

It is built for the simple moment where you have a set of apps, folders, files, and links open, you need to stop, and you want a fast way to get back into that same work later without rebuilding it from memory.

## What Entule Does

Entule helps you do four main things:

- save your current work setup as a checkpoint
- reopen your latest checkpoint
- create reusable presets for setups you use often
- manage everything from a menu bar app with a dedicated app window

## How The App Works

When you open Entule, you get one main app window with a few core sections.

### Overview

Overview is the home screen.

It gives you quick access to the most important actions:

- **Save Current Session**: capture what you are working on right now
- **Resume Last Session**: reopen your most recently saved checkpoint
- **Manage Presets**: create or edit reusable launch setups

Overview also shows:

- your latest saved checkpoint
- how many items are in it
- your saved presets
- a short status area so you can see what Entule is doing

### Save Session

Save Session is where you create a checkpoint.

When you open it, Entule tries to detect what it can from your current workspace, including:

- currently running apps
- Finder folders
- Safari links
- Google Chrome links

You can then review the result before saving.

In Save Session you can:

- keep or uncheck detected items
- remove items you do not want in the checkpoint
- add an app manually
- add a file manually
- add a folder manually
- add a URL manually
- write a note for the checkpoint
- optionally attach a Shortcut name

This means Entule does not just blindly save everything it finds. You get a review step first.

### Resume Last Session

Resume Last Session reopens the items from your most recent checkpoint.

That can include:

- apps
- folders
- files
- URLs

If you saved a note with the checkpoint, you can inspect that checkpoint inside the app as well.

After a resume, Entule shows a result summary so you can see:

- how many items it tried to open
- how many succeeded
- how many failed
- how many were skipped

If something could not be reopened, Entule shows that clearly instead of silently failing.

### Inspect Checkpoint

Inspect Checkpoint lets you look at the details of your latest saved checkpoint without reopening it first.

This is useful when you want to:

- review what was saved
- read the note you attached
- check which apps, files, folders, and links are included
- decide whether you want to resume it

### Presets

Presets are for repeatable setups you use often.

A preset is not tied to what you are doing right now. It is a saved launch setup you make on purpose.

You can use presets for things like:

- a writing setup
- a research setup
- a client setup
- a morning startup setup

In Presets you can:

- create a new preset
- name the preset
- add apps
- add files
- add folders
- add URLs
- reorder items
- edit existing presets
- delete presets
- launch a preset at any time
- optionally attach a Shortcut name

### Settings

Settings gives you a few practical controls for using and testing Entule.

In Settings you can:

- see guidance about app permissions
- reveal the Entule data folder in Finder
- reveal the saved `state.json` file
- clear only the latest saved checkpoint
- reset all local Entule data
- view a small diagnostics summary
- copy that diagnostics summary

This section is mainly there to help you manage the app cleanly on your own Mac.

## Menu Bar Access

Entule lives in the menu bar so you can get to it quickly.

From the menu bar you can:

- open the main Entule window
- resume the last session
- save the current session
- open presets
- open settings
- quit the app

The menu bar is the quick access point. The main app window is where you review, edit, and manage everything.

## What Gets Saved In A Checkpoint

A checkpoint can include:

- apps
- files
- folders
- URLs
- a short note
- an optional Shortcut name

That gives you a lightweight way to save the shape of your work without pretending to save every exact internal detail of every app.

## What Resume Actually Does

When you resume a checkpoint, Entule reopens the things you saved.

That means it can:

- reopen an app
- reopen a folder in Finder
- reopen a file
- reopen a saved URL
- run a named Shortcut if you attached one

Entule does **not** claim to restore the exact internal state of every app.

It is designed to reopen your saved work resources, not to fully reconstruct every tab, panel, cursor position, or window layout inside third-party apps.

## Permissions

To detect Finder, Safari, and Chrome content, Entule may need macOS Automation permission.

If detection appears empty when those apps are open, check your Mac's Privacy & Security settings and allow Entule to interact with the apps you want it to detect.

## Privacy

Entule stores its data locally on your Mac.

It does not use cloud sync in v1.

Your local app data is stored here:

`~/Library/Application Support/Entule/state.json`

## Current Limitations

Entule is intentionally focused.

A few things to know:

- browser and Finder detection are best effort
- Entule reopens saved resources, but it does not restore exact internal app state
- window layouts and monitor layouts are not restored
- some third-party apps may respond differently when macOS tries to reopen them
- URLs can only be reopened if they were detected or manually saved

## Local Install

If you are building from source, you can install Entule into Applications with:

```bash
swift build
./scripts/install-local-app.sh
```

You can also create a local DMG with:

```bash
./scripts/create-dmg.sh
```

## Download A Built App

If you just want the packaged app from GitHub Releases, use this bash one-liner:

```bash
curl -L -o /tmp/Entule.dmg \
  $(curl -fsSL https://api.github.com/repos/derinbarutcu17/Entule/releases/latest \
    | python3 - <<'PY'
import json, sys

data = json.load(sys.stdin)
for asset in data.get('assets', []):
    if asset.get('name', '').endswith('.dmg'):
        print(asset['browser_download_url'])
        break
else:
    raise SystemExit('No .dmg asset found in the latest release')
PY
  )
open /tmp/Entule.dmg
```

Or, if you prefer a script from the repo, run:

```bash
./scripts/download-latest-release.sh
```

That script downloads the latest `.dmg` release asset into your Downloads folder and opens it.

