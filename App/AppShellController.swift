import AppKit
import SwiftUI

@MainActor
final class AppShellController: NSObject, NSWindowDelegate {
    private var primaryWindow: NSWindow?
    private var primaryHostingController: NSHostingController<EntuleDashboardView>?
    private var hasAppliedLaunchDefaultSize = false
    private let appShellViewModel: AppShellViewModel
    private let workspaceViewModel: WorkspaceViewModel

    init(appShellViewModel: AppShellViewModel, workspaceViewModel: WorkspaceViewModel) {
        self.appShellViewModel = appShellViewModel
        self.workspaceViewModel = workspaceViewModel
        super.init()
    }

    func showMainWindow(section: AppSection? = nil) {
        if let section = section {
            appShellViewModel.navigate(to: section)
        }

        if let existing = primaryWindow {
            applyWindowConstraints(to: existing)
            applyLaunchDefaultSizeIfNeeded(to: existing)
            reveal(window: existing, stealFocus: false)
            return
        }

        let view = EntuleDashboardView(appShellViewModel: appShellViewModel, workspaceViewModel: workspaceViewModel)
        let hostingController = NSHostingController(rootView: view)

        let targetSize = launchContentSize(for: NSScreen.main)
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: targetSize),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Entule"
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.toolbarStyle = .unifiedCompact
        window.backgroundColor = .clear
        window.isOpaque = false
        window.isMovableByWindowBackground = false
        window.isReleasedWhenClosed = false
        applyWindowConstraints(to: window)
        window.delegate = self
        window.contentViewController = hostingController
        applyLaunchFrame(to: window, center: true)
        hasAppliedLaunchDefaultSize = true

        primaryWindow = window
        primaryHostingController = hostingController
        reveal(window: window, stealFocus: true)
    }

    func focusMainWindow() {
        guard let window = primaryWindow else { return }
        reveal(window: window, stealFocus: true)
    }

    func hideToMenuBarIfPossible() {
        let hasVisibleWindow = NSApp.windows.contains { window in
            window.isVisible && !window.isMiniaturized
        }

        if !hasVisibleWindow {
            NSApp.setActivationPolicy(.accessory)
        }
    }

    func handleAppReopen() {
        let hasVisibleWindow = NSApp.windows.contains { window in
            window.isVisible && !window.isMiniaturized
        }

        if !hasVisibleWindow {
            showMainWindow(section: appShellViewModel.activeSection)
        } else {
            focusMainWindow()
        }
    }

    func refreshWindowContent() {
        guard let hostingController = primaryHostingController else { return }
        hostingController.rootView = EntuleDashboardView(
            appShellViewModel: appShellViewModel,
            workspaceViewModel: workspaceViewModel
        )
    }

    // MARK: - NSWindowDelegate

    func windowWillClose(_ notification: Notification) {
        hideToMenuBarIfPossible()
    }

    func windowDidMiniaturize(_ notification: Notification) {
        hideToMenuBarIfPossible()
    }

    func windowDidDeminiaturize(_ notification: Notification) {
        guard let window = primaryWindow else { return }
        reveal(window: window, stealFocus: false)
    }


    private func applyWindowConstraints(to window: NSWindow) {
        let minimumSize = NSSize(
            width: AppWindowMetrics.minimumWindowWidth,
            height: AppWindowMetrics.minimumWindowHeight
        )

        window.contentMinSize = minimumSize
        window.minSize = minimumSize

        let safeWidth = max(window.frame.width, minimumSize.width)
        let safeHeight = max(window.frame.height, minimumSize.height)

        if window.frame.width < minimumSize.width || window.frame.height < minimumSize.height {
            window.setContentSize(NSSize(width: safeWidth, height: safeHeight))
        }
    }

    private func reveal(window: NSWindow, stealFocus: Bool) {
        NSApp.setActivationPolicy(.regular)
        if stealFocus {
            NSApp.activate(ignoringOtherApps: true)
        }

        window.level = .normal
        window.collectionBehavior = []

        if window.isVisible {
            window.makeKey()
            window.orderFront(nil)
        } else {
            window.makeKeyAndOrderFront(nil)
        }
    }

    private func applyLaunchDefaultSizeIfNeeded(to window: NSWindow) {
        guard !hasAppliedLaunchDefaultSize else { return }

        let minWidth = AppWindowMetrics.minimumWindowWidth
        let minHeight = AppWindowMetrics.minimumWindowHeight
        let current = window.contentRect(forFrameRect: window.frame).size

        // If macOS restored a stale minimum-sized window, promote it to the configured launch default.
        if current.width <= (minWidth + 1), current.height <= (minHeight + 1) {
            applyLaunchFrame(to: window, center: true)
        }

        hasAppliedLaunchDefaultSize = true
    }

    private func launchContentSize(for screen: NSScreen?) -> NSSize {
        let minSize = NSSize(
            width: AppWindowMetrics.minimumWindowWidth,
            height: AppWindowMetrics.minimumWindowHeight
        )
        let targetSize = NSSize(
            width: AppWindowMetrics.defaultWindowWidth,
            height: AppWindowMetrics.defaultWindowHeight
        )

        guard let screen else { return targetSize }

        // Keep a small margin from screen edges so macOS can position title bar comfortably.
        let visible = screen.visibleFrame.insetBy(dx: 40, dy: 40).size
        let maxWidth = max(minSize.width, visible.width)
        let maxHeight = max(minSize.height, visible.height)

        return NSSize(
            width: min(max(targetSize.width, minSize.width), maxWidth),
            height: min(max(targetSize.height, minSize.height), maxHeight)
        )
    }

    private func applyLaunchFrame(to window: NSWindow, center: Bool) {
        let size = launchContentSize(for: window.screen ?? NSScreen.main)
        let frameRect = window.frameRect(forContentRect: NSRect(origin: .zero, size: size))

        window.setFrame(frameRect, display: false)
        if center {
            window.center()
        }
    }

    func testOnlyHasPrimaryHostingController() -> Bool {
        primaryHostingController != nil
    }
}
