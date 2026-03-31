import Foundation

protocol FileExistenceChecking {
    func fileExists(atPath path: String) -> Bool
}

extension FileManager: FileExistenceChecking {}

enum AppLaunchResolution {
    case resolved(URL)
    case failed(String)
}

struct AppLaunchResolver {
    let fileChecker: FileExistenceChecking
    let installedAppResolver: InstalledAppResolving

    init(
        fileChecker: FileExistenceChecking = FileManager.default,
        installedAppResolver: InstalledAppResolving
    ) {
        self.fileChecker = fileChecker
        self.installedAppResolver = installedAppResolver
    }

    func resolve(item: SessionItem) -> AppLaunchResolution {
        if let appPath = item.appPath ?? optionalPath(from: item.value),
           fileChecker.fileExists(atPath: appPath) {
            return .resolved(URL(fileURLWithPath: appPath))
        }

        if looksLikeBundleIdentifier(item.value),
           let bundleURL = installedAppResolver.appURL(forBundleIdentifier: item.value),
           fileChecker.fileExists(atPath: bundleURL.path) {
            return .resolved(bundleURL)
        }

        let pathHint = item.appPath ?? optionalPath(from: item.value)
        if let pathHint {
            return .failed("App path missing or invalid at \(pathHint) and bundle lookup failed")
        }
        if looksLikeBundleIdentifier(item.value) {
            return .failed("Bundle lookup failed for \(item.value)")
        }
        return .failed("No appPath and no valid bundle identifier for app item")
    }

    private func optionalPath(from value: String) -> String? {
        if value.hasPrefix("/") { return value }
        return nil
    }

    private func looksLikeBundleIdentifier(_ value: String) -> Bool {
        !value.contains("/") && value.contains(".")
    }
}
