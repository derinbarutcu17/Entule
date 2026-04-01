import AppKit
import Foundation

@MainActor
enum OpenPanelCoordinator {
    static func runModal(_ panel: NSOpenPanel) -> NSApplication.ModalResponse {
        let parentWindow = NSApp.keyWindow ?? NSApp.mainWindow
        let response = panel.runModal()
        parentWindow?.makeKeyAndOrderFront(nil)
        return response
    }
}
