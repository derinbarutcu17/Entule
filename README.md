# Entule

## Download Latest Release

- [Download Entule.app.zip](https://github.com/derinbarutcu17/Entule/releases/latest/download/Entule.app.zip)

## Installation

Because Entule is an independent, open-source tool, macOS may show a security warning the first time you open it. That is normal for apps that are downloaded from the internet and are not signed with an Apple Developer ID yet.

```bash
curl -fL --retry 3 -o ~/Downloads/Entule.app.zip https://github.com/derinbarutcu17/Entule/releases/latest/download/Entule.app.zip
```

**Step 1: Download Entule**
1. Download [Entule.app.zip](https://github.com/derinbarutcu17/Entule/releases/latest/download/Entule.app.zip).
2. If you used the Terminal command above, the file will usually be in your `Downloads` folder.

**Step 2: Unzip Entule**
1. Double-click the ZIP file.
2. macOS will create a folder named `Entule`.
3. Open that folder.

**Step 3: Move Entule into Applications**
1. Drag `Entule.app` into your `Applications` folder.
2. If macOS asks to replace an older copy, choose the newer one if you want the latest version.
3. Keeping the app in `Applications` makes it easier to find later and keeps your Mac tidy.

**Step 4: Open Entule safely**
1. Open your `Applications` folder.
2. Right-click `Entule.app`.
3. Click `Open`.
4. If macOS warns you again, click `Open` one more time.
5. The app should then launch normally in the future.

<details>
  <summary>Getting an "App is damaged" error?</summary>
  macOS sometimes aggressively flags browser downloads. Open Terminal and run this if the app still will not open after the steps above:
  <br>
  <code>xattr -cr /Applications/Entule.app</code>
</details>

## What Entule Does And How To Use It

Entule is a macOS app that saves your current work context and helps you reopen it later.

What it does:
- Saves apps, files, folders, and links into one session checkpoint
- Lets you inspect the saved session before reopening
- Supports quick save from the home screen
- Supports reusable presets for common launch setups
- Stores data locally on your Mac

How to use:
1. Install Entule by downloading the ZIP release, unzipping it, moving `Entule.app` into `Applications`, and opening it with right-click > `Open` the first time.
2. Open Entule and go to `Save` to capture your current session.
3. Use `Inspect` to review saved items.
4. Click `Resume` to reopen saved items.
5. Use `Presets` to save reusable launch setups.
6. Use `Settings` only when you need permissions or reset actions.
