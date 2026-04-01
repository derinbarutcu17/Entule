import AppKit

enum WindowCoordinator {
    @MainActor
    static func enterWindowMode() {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    @MainActor
    static func enterMenuBarModeIfPossible() {
        let hasVisibleWindow = NSApp.windows.contains { window in
            window.isVisible && !window.isMiniaturized
        }

        if !hasVisibleWindow {
            NSApp.setActivationPolicy(.accessory)
        }
    }

    @MainActor
    static func activate(window: NSWindow?) {
        guard let window else { return }
        enterWindowMode()
        window.level = .normal
        window.collectionBehavior = []
        if window.isVisible {
            window.makeKey()
            window.orderFront(nil)
        } else {
            window.makeKeyAndOrderFront(nil)
        }
    }

    @MainActor
    static func focusPrimaryWindow() {
        enterWindowMode()
        if let window = NSApp.windows.first(where: { $0.isVisible }) ?? NSApp.windows.first {
            window.makeKeyAndOrderFront(nil)
        }
    }
}
