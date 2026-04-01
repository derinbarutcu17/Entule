import AppKit
import SwiftUI

@MainActor
final class AppWindowController {
    static let shared = AppWindowController()

    private var primaryWindow: NSWindow?
    private let windowDelegate = PrimaryWindowDelegate()

    private init() {}

    func showDashboard(menuBarViewModel: MenuBarViewModel, section: AppSection = .home) {
        menuBarViewModel.navigate(to: section)
        let view = EntuleDashboardView(menuBarViewModel: menuBarViewModel)
        primaryWindow = showWindow(
            existing: primaryWindow,
            title: "Entule",
            size: NSSize(width: 980, height: 660),
            rootView: view
        )
    }

    func showPresets(menuBarViewModel: MenuBarViewModel) {
        showDashboard(menuBarViewModel: menuBarViewModel, section: .presets)
    }

    func showSaveSession(menuBarViewModel: MenuBarViewModel) {
        showDashboard(menuBarViewModel: menuBarViewModel, section: .saveSession)
    }

    func showResumeSession(menuBarViewModel: MenuBarViewModel) {
        showDashboard(menuBarViewModel: menuBarViewModel, section: .resumeSession)
    }

    func showSettings(menuBarViewModel: MenuBarViewModel) {
        showDashboard(menuBarViewModel: menuBarViewModel, section: .settings)
    }

    private func showWindow<Content: View>(
        existing: NSWindow?,
        title: String,
        size: NSSize,
        rootView: Content
    ) -> NSWindow {
        if let existing {
            existing.contentViewController = NSHostingController(rootView: rootView)
            existing.title = title
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
        window.title = ""
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = false
        window.toolbarStyle = .automatic
        window.backgroundColor = .windowBackgroundColor
        window.isOpaque = true
        window.isMovableByWindowBackground = false
        window.isReleasedWhenClosed = false
        window.minSize = size
        window.setContentSize(size)
        window.center()
        window.delegate = windowDelegate
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

private final class PrimaryWindowDelegate: NSObject, NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        WindowCoordinator.enterMenuBarModeIfPossible()
    }

    func windowDidMiniaturize(_ notification: Notification) {
        WindowCoordinator.enterMenuBarModeIfPossible()
    }

    func windowDidDeminiaturize(_ notification: Notification) {
        WindowCoordinator.enterWindowMode()
    }
}
