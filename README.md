# Entule

Entule is a macOS menu bar utility that saves and reopens a lightweight work session.

## What It Does (v1)

- Runs as a menu bar-only app (`LSUIElement = true`)
- Lets you create presets containing apps, files, folders, and URLs
- Lets you detect a "current session" (best effort), review it, and save it
- Lets you manually add apps, files, folders, and URLs during Save Current Session
- Lets you resume the last saved session
- Optionally runs a user-selected macOS Shortcut before launch/resume
- App launch tries `appPath` first, then bundle identifier fallback if needed

## What It Does Not Do (v1)

- No notch UI
- No LLM or AI suggestions
- No browser session manager
- No cloud sync
- No background auto-capture daemon
- No onboarding flow
- No analytics/subscription/paywall

## Supported Detection (v1)

- Running apps (`NSWorkspace`)
- Finder target folders (best effort AppleScript)
- Safari active tabs (best effort AppleScript)
- Google Chrome active tabs (best effort AppleScript)

Manual-only for v1:

- Slack
- Photoshop documents
- Cursor/Codex
- ChatGPT
- WhatsApp
- Figma desktop app

## Privacy

- State is stored locally in:
  - `~/Library/Application Support/Entule/state.json`
- Legacy migration:
  - If Entule state is missing but `~/Library/Application Support/WorkCheckpoint/state.json` exists, Entule imports it once.
- No remote storage is used in v1.

## Run Locally (macOS)

1. Clone the repo.
2. Run `swift build`.
3. Run `swift run Entule` or open the package in Xcode and run the app target.
4. Confirm the app appears in the menu bar (not in Dock).

## Automation Permissions (Finder/Safari/Chrome)

- If browser or Finder detection is empty, open:
  - `System Settings > Privacy & Security > Automation`
- Allow Entule to control Finder, Safari, and Google Chrome.
- Entule treats "not running" apps as normal state, not an error.

## Storage and Migration

- Primary state path:
  - `~/Library/Application Support/Entule/state.json`
- Legacy import:
  - If Entule state is missing and `~/Library/Application Support/WorkCheckpoint/state.json` exists, Entule imports it once at startup.

## First Manual Test Flow

1. Create one preset with an app, folder, and URL.
2. Launch the preset from the menu.
3. Use `Save Current Session`, uncheck one item, then save.
4. Use `Resume Last Session` and verify attempted/succeeded/failed/skipped counts.
5. Test one broken path/URL to confirm failure reporting is clear and non-crashing.

## Reset During Testing

- Open `Settings > Testing & Storage` and use:
  - `Reveal Entule Data Folder`
  - `Reveal state.json`
  - `Clear Last Snapshot`
  - `Reset All Local Data`
- `Reset All Local Data` recreates a clean empty state automatically.

## Known Limitations

- No exact internal app state restoration
- Browser/Finder detection is best effort
- Browser/Finder "not running" is treated as normal state, not an error
- No window layout restore in v1
- URLs only restore if they were captured or manually saved
- Focus behavior depends on user-created Shortcuts

## Technical Baseline

- Swift + SwiftUI app lifecycle
- `MenuBarExtra` shell
- AppKit interop where needed (`NSOpenPanel`, `NSWorkspace`)
- JSON persistence in Application Support
- AppleScript/Apple Events for selective detection only
- `shortcuts` CLI for Focus/Do Not Disturb hooks

## Manual QA Checklist

- Create preset
- Edit preset
- Delete preset
- Launch preset
- Save session
- Uncheck some detected items
- Resume last session
- Missing file path behavior
- Bad URL behavior
- Safari open / closed
- Chrome open / closed
- Finder open / closed
- Shortcut exists / missing
