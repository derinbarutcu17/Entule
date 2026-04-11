import AppKit
import Foundation
import OSLog

final class AppLauncher: Launcher {
    private let workspace: NSWorkspace
    private let shortcutRunner: ShortcutRunner
    private let logger: Logger

    init(
        workspace: NSWorkspace = .shared,
        shortcutRunner: ShortcutRunner = ShortcutRunner(),
        logger: Logger = Logger(subsystem: "com.entule.app", category: "AppLauncher")
    ) {
        self.workspace = workspace
        self.shortcutRunner = shortcutRunner
        self.logger = logger
    }

    func launch(items: [SessionItem], shortcutName: String?, dryRun: Bool = false) async -> LaunchReport {
        var report = LaunchReport()
        let dedupeResult = dedupe(items: items)
        let normalized = dedupeResult.items.filter(\.isSelected)

        report.attemptedItems = normalized
        report.skipped.append(contentsOf: dedupeResult.skipped)

        if let shortcutName, !shortcutName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if dryRun {
                report.shortcutResult = ShortcutExecutionResult(name: shortcutName, succeeded: true, output: "dry-run", errorOutput: "", exitCode: 0)
            } else {
                report.shortcutResult = shortcutRunner.run(name: shortcutName)
            }
        }

        let apps = normalized.filter { $0.kind == .app }
        let filesAndFolders = normalized.filter { $0.kind == .file || $0.kind == .folder }
        let urls = normalized.filter { $0.kind == .url }

        await launchGroup(apps, dryRun: dryRun, report: &report)
        try? await Task.sleep(nanoseconds: 150_000_000)
        await launchGroup(filesAndFolders, dryRun: dryRun, report: &report)
        try? await Task.sleep(nanoseconds: 150_000_000)
        await launchGroup(urls, dryRun: dryRun, report: &report)

        return report
    }

    private func launchGroup(_ items: [SessionItem], dryRun: Bool, report: inout LaunchReport) async {
        for item in items {
            if dryRun {
                report.successes.append(item)
                continue
            }

            switch item.kind {
            case .app:
                await launchApp(item, report: &report)
            case .file, .folder:
                launchPath(item, report: &report)
            case .url:
                launchURL(item, report: &report)
            }
        }
    }

    private func launchApp(_ item: SessionItem, report: inout LaunchReport) async {
        guard let appURL = resolveAppURL(for: item) else {
            report.failures.append(LaunchIssue(item: item, reason: "Could not resolve app path or bundle ID"))
            return
        }

        let config = NSWorkspace.OpenConfiguration()
        do {
            _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<NSRunningApplication, Error>) in
                workspace.openApplication(at: appURL, configuration: config) { runningApp, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let runningApp = runningApp {
                        continuation.resume(returning: runningApp)
                    } else {
                        continuation.resume(throwing: NSError(domain: "AppLauncher", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown launch error"]))
                    }
                }
            }
            report.successes.append(item)
        } catch {
            if fallbackLaunch(item: item, resolvedAppURL: appURL) {
                logger.info("Fallback launch succeeded for \(item.displayName)")
                report.successes.append(item)
            } else {
                logger.error("App launch failed: \(item.displayName) :: \(error.localizedDescription)")
                report.failures.append(LaunchIssue(item: item, reason: "\(error.localizedDescription). Fallback open also failed"))
            }
        }
    }

    private func resolveAppURL(for item: SessionItem) -> URL? {
        if let appPath = item.appPath ?? (item.value.hasPrefix("/") ? item.value : nil),
           FileManager.default.fileExists(atPath: appPath) {
            return URL(fileURLWithPath: appPath)
        }

        if looksLikeBundleIdentifier(item.value) {
            return workspace.urlForApplication(withBundleIdentifier: item.value)
        }

        return nil
    }

    private func fallbackLaunch(item: SessionItem, resolvedAppURL: URL) -> Bool {
        let launchPath = "/usr/bin/open"
        let arguments: [String]
        
        if looksLikeBundleIdentifier(item.value) {
            arguments = ["-b", item.value]
        } else {
            arguments = ["-a", resolvedAppURL.path]
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: launchPath)
        process.arguments = arguments

        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }

    private func launchPath(_ item: SessionItem, report: inout LaunchReport) {
        let path = item.value
        guard FileManager.default.fileExists(atPath: path) else {
            report.failures.append(LaunchIssue(item: item, reason: "Path missing: \(path)"))
            return
        }

        if workspace.open(URL(fileURLWithPath: path)) {
            report.successes.append(item)
        } else {
            report.failures.append(LaunchIssue(item: item, reason: "NSWorkspace.open returned false"))
        }
    }

    private func launchURL(_ item: SessionItem, report: inout LaunchReport) {
        guard let normalized = URLNormalizer.normalize(item.value), let url = URL(string: normalized) else {
            report.failures.append(LaunchIssue(item: item, reason: "Invalid URL: \(item.value)"))
            return
        }

        if workspace.open(url) {
            report.successes.append(item)
        } else {
            report.failures.append(LaunchIssue(item: item, reason: "NSWorkspace.open returned false"))
        }
    }

    private func dedupe(items: [SessionItem]) -> (items: [SessionItem], skipped: [LaunchIssue]) {
        var seen = Set<String>()
        var deduped: [SessionItem] = []
        var skipped: [LaunchIssue] = []

        for item in items {
            let key: String
            switch item.kind {
            case .app:
                key = "app::\((item.appPath ?? item.value).lowercased())"
            case .file:
                key = "file::\(item.value)"
            case .folder:
                key = "folder::\(item.value)"
            case .url:
                key = "url::\(URLNormalizer.normalize(item.value) ?? item.value)"
            }

            if seen.contains(key) {
                skipped.append(LaunchIssue(item: item, reason: "Duplicate item"))
                continue
            }

            seen.insert(key)
            deduped.append(item)
        }

        return (deduped, skipped)
    }

    private func looksLikeBundleIdentifier(_ value: String) -> Bool {
        !value.contains("/") && value.contains(".")
    }
}
