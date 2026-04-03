import AppKit
import SwiftUI

@MainActor
final class AppShellController: NSObject, NSWindowDelegate {
    private var primaryWindow: NSWindow?
    private var primaryHostingController: NSHostingController<EntuleDashboardView>?
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
            reveal(window: existing, stealFocus: false)
            return
        }

        let view = EntuleDashboardView(appShellViewModel: appShellViewModel, workspaceViewModel: workspaceViewModel)
        let hostingController = NSHostingController(rootView: view)

        let targetSize = NSSize(width: AppWindowMetrics.defaultWindowWidth, height: AppWindowMetrics.defaultWindowHeight)
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
        window.minSize = NSSize(
            width: AppWindowMetrics.minimumWindowWidth,
            height: AppWindowMetrics.minimumWindowHeight
        )
        window.setContentSize(targetSize)
        window.center()
        window.delegate = self
        window.contentViewController = hostingController

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

    func testOnlyHasPrimaryHostingController() -> Bool {
        primaryHostingController != nil
    }
}
