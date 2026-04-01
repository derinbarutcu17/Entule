import AppKit
import SwiftUI

@MainActor
struct WindowAccessor: NSViewRepresentable {
    let onResolve: @MainActor (NSWindow?) -> Void

    final class Coordinator {
        var lastWindowID: ObjectIdentifier?
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            resolve(window: view.window, coordinator: context.coordinator)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            resolve(window: nsView.window, coordinator: context.coordinator)
        }
    }

    private func resolve(window: NSWindow?, coordinator: Coordinator) {
        guard let window else { return }
        let identifier = ObjectIdentifier(window)
        guard coordinator.lastWindowID != identifier else { return }
        coordinator.lastWindowID = identifier
        onResolve(window)
    }
}

enum WindowCoordinator {
    @MainActor
    static func activateApp() {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    @MainActor
    static func activate(window: NSWindow?) {
        guard let window else { return }
        activateApp()
        window.level = .normal
        window.collectionBehavior.insert(.moveToActiveSpace)
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
    }

    @MainActor
    static func focusPrimaryWindow() {
        activateApp()
        if let window = NSApp.windows.first(where: { $0.isVisible }) ?? NSApp.windows.first {
            window.makeKeyAndOrderFront(nil)
            window.orderFrontRegardless()
        }
    }
}
