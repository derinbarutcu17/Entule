import AppKit
import Foundation

final class AppDetector: DetectorProtocol {
    let name = "AppDetector"

    func detect() async -> [SessionItem] {
        let runningApps = NSWorkspace.shared.runningApplications

        return runningApps.compactMap { app in
            guard let bundleID = app.bundleIdentifier,
                  let appURL = app.bundleURL,
                  app.activationPolicy == .regular else {
                return nil
            }

            if bundleID == Bundle.main.bundleIdentifier { return nil }
            if bundleID.hasPrefix("com.apple.") && (appURL.path.contains("/System/") || app.localizedName == nil) {
                return nil
            }

            let displayName = app.localizedName ?? bundleID
            return SessionItem(
                kind: .app,
                displayName: displayName,
                value: bundleID,
                appPath: appURL.path,
                source: "detected-app",
                isSelected: true
            )
        }
    }
}
