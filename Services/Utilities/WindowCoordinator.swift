import AppKit

enum WindowCoordinator {
    @MainActor
    static func activateApp() {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: false)
    }

    @MainActor
    static func activate(window: NSWindow?) {
        guard let window else { return }
        activateApp()
        window.level = .normal
        window.collectionBehavior = [.managed]
        window.makeKeyAndOrderFront(nil)
    }

    @MainActor
    static func focusPrimaryWindow() {
        activateApp()
        if let window = NSApp.windows.first(where: { $0.isVisible }) ?? NSApp.windows.first {
            window.makeKeyAndOrderFront(nil)
        }
    }
}
