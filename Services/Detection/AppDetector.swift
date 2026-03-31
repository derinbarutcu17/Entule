import AppKit
import Foundation

final class AppDetector: DetectorProtocol {
    let name = "AppDetector"

    func detect() async -> DetectorOutput {
        let runningApps = NSWorkspace.shared.runningApplications
        let items: [SessionItem] = runningApps.compactMap { app -> SessionItem? in
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

        return DetectorOutput(detectorName: name, items: items, warnings: [], failed: false)
    }
}
