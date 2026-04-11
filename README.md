# Entule

## Installation

Because Entule is an independent, open-source tool, macOS requires a quick workaround to bypass Gatekeeper on the first launch. 

**Option 1: The Magic Command (Recommended)**
Downloading via Terminal completely bypasses Apple's quarantine warning. Open Terminal and paste this:

```bash
curl -fL --retry 3 -o ~/Downloads/Entule.dmg [https://github.com/derinbarutcu17/Entule/releases/latest/download/Entule.dmg](https://github.com/derinbarutcu17/Entule/releases/latest/download/Entule.dmg) && open ~/Downloads/Entule.dmg
```

Drag `Entule.app` to your Applications folder, and it will open normally.

**Option 2: The Manual Download**
1. Download [Entule.dmg](https://github.com/derinbarutcu17/Entule/releases/latest/download/Entule.dmg).
2. Drag `Entule.app` into your Applications folder.
3. **Right-click** (or Control-click) `Entule.app` and select **Open**. Confirm the prompt. *(You only have to do this once).*

<details>
  <summary>Getting an "App is damaged" error?</summary>
  macOS sometimes aggressively flags browser downloads. Open Terminal and run this to strip the quarantine flag:
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
1. Install Entule by opening the DMG and dragging Entule to Applications.
2. Open Entule and go to `Save` to capture your current session.
3. Use `Inspect` to review saved items.
4. Click `Resume` to reopen saved items.
5. Use `Presets` to save reusable launch setups.
6. Use `Settings` only when you need permissions or reset actions.
