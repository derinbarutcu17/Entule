# Entule

Entule is a macOS menu bar utility that saves and reopens a lightweight work session.

## What It Does (v1)

- Runs as a menu bar-only app (`LSUIElement = true`)
- Lets you create presets containing apps, files, folders, and URLs
- Lets you detect a "current session" (best effort), review it, and save it
- Lets you resume the last saved session
- Optionally runs a user-selected macOS Shortcut before launch/resume

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
- No remote storage is used in v1.

## Known Limitations

- No exact internal app state restoration
- Browser/Finder detection is best effort
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
