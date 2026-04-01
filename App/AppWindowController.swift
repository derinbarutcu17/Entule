import AppKit
import SwiftUI

@MainActor
final class AppWindowController {
    static let shared = AppWindowController()

    private var dashboardWindow: NSWindow?
    private var presetsWindow: NSWindow?
    private var saveSessionWindow: NSWindow?
    private var resumeSessionWindow: NSWindow?
    private var settingsWindow: NSWindow?

    private init() {}

    func showDashboard(menuBarViewModel: MenuBarViewModel) {
        let view = EntuleDashboardView(menuBarViewModel: menuBarViewModel)
        dashboardWindow = showWindow(
            existing: dashboardWindow,
            title: "Entule",
            size: NSSize(width: 760, height: 560),
            rootView: view
        )
    }

    func showPresets(menuBarViewModel: MenuBarViewModel) {
        let view = PresetManagementView(menuBarViewModel: menuBarViewModel)
        presetsWindow = showWindow(
            existing: presetsWindow,
            title: "Presets",
            size: NSSize(width: 860, height: 620),
            rootView: view
        )
    }

    func showSaveSession(menuBarViewModel: MenuBarViewModel) {
        let view = SaveSessionSheet(
            viewModel: SaveSessionViewModel(),
            menuBarViewModel: menuBarViewModel
        )
        saveSessionWindow = showWindow(
            existing: saveSessionWindow,
            title: "Save Current Session",
            size: NSSize(width: 920, height: 680),
            rootView: view
        )
    }

    func showResumeSession(menuBarViewModel: MenuBarViewModel) {
        let rootView: AnyView
        if let snapshot = menuBarViewModel.lastSnapshot {
            rootView = AnyView(
                ResumeSessionSheet(
                    viewModel: ResumeSessionViewModel(snapshot: snapshot),
                    menuBarViewModel: menuBarViewModel
                )
            )
        } else {
            rootView = AnyView(
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)
                    Text("No Checkpoint Saved")
                        .font(.headline)
                    Text("Save a current session first, then come back to resume it.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .padding(24)
                .frame(minWidth: 480, minHeight: 240)
            )
        }

        resumeSessionWindow = showWindow(
            existing: resumeSessionWindow,
            title: "Resume Last Session",
            size: NSSize(width: 760, height: 560),
            rootView: rootView
        )
    }

    func showSettings(menuBarViewModel: MenuBarViewModel) {
        let view = SettingsView(menuBarViewModel: menuBarViewModel)
        settingsWindow = showWindow(
            existing: settingsWindow,
            title: "Settings",
            size: NSSize(width: 620, height: 620),
            rootView: view
        )
    }

    private func showWindow<Content: View>(
        existing: NSWindow?,
        title: String,
        size: NSSize,
        rootView: Content
    ) -> NSWindow {
        if let existing {
            existing.contentViewController = NSHostingController(rootView: rootView)
            enforceMinimumSize(on: existing, targetSize: size)
            WindowCoordinator.activate(window: existing)
            return existing
        }

        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = title
        window.isReleasedWhenClosed = false
        window.minSize = size
        window.setContentSize(size)
        window.center()
        window.contentViewController = NSHostingController(rootView: rootView)
        WindowCoordinator.activate(window: window)
        return window
    }

    private func enforceMinimumSize(on window: NSWindow, targetSize: NSSize) {
        window.minSize = targetSize

        let frame = window.frame
        let width = max(frame.width, targetSize.width)
        let height = max(frame.height, targetSize.height)
        if width != frame.width || height != frame.height {
            let newFrame = NSRect(
                x: frame.origin.x,
                y: frame.origin.y - (height - frame.height),
                width: width,
                height: height
            )
            window.setFrame(newFrame, display: true, animate: false)
        }
    }

    func testOnlyEnforceMinimumSize(on window: NSWindow, targetSize: NSSize) {
        enforceMinimumSize(on: window, targetSize: targetSize)
    }
}
