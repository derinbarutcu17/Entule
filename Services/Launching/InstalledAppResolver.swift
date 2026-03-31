import AppKit
import Foundation

protocol InstalledAppResolving {
    func appURL(forBundleIdentifier bundleIdentifier: String) -> URL?
}

struct NSWorkspaceInstalledAppResolver: InstalledAppResolving {
    private let workspace: NSWorkspace

    init(workspace: NSWorkspace = .shared) {
        self.workspace = workspace
    }

    func appURL(forBundleIdentifier bundleIdentifier: String) -> URL? {
        workspace.urlForApplication(withBundleIdentifier: bundleIdentifier)
    }
}
