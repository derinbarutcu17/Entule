import AppKit
import Foundation

enum BundleAppResolver {
    static func bundleIdentifier(forAppPath appPath: String) -> String? {
        Bundle(path: appPath)?.bundleIdentifier
    }

    static func displayName(forAppPath appPath: String) -> String {
        let url = URL(fileURLWithPath: appPath)
        if let bundleName = Bundle(path: appPath)?.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
            return bundleName
        }
        if let bundleName = Bundle(path: appPath)?.object(forInfoDictionaryKey: "CFBundleName") as? String {
            return bundleName
        }
        return url.deletingPathExtension().lastPathComponent
    }
}
