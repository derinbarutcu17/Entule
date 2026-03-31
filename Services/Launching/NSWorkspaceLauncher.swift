import AppKit
import Foundation

final class NSWorkspaceLauncher: Launcher {
    private let workspace: NSWorkspace
    private let shortcutRunner: ShortcutRunner
    private let logger: Logger

    init(
        workspace: NSWorkspace = .shared,
        shortcutRunner: ShortcutRunner = ShortcutRunner(),
        logger: Logger = .shared
    ) {
        self.workspace = workspace
        self.shortcutRunner = shortcutRunner
        self.logger = logger
    }

    func launch(items: [SessionItem], shortcutName: String?, dryRun: Bool = false) async -> LaunchReport {
        var report = LaunchReport()
        let normalized = dedupe(items: items).filter(\.isSelected)

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
                launchApp(item, report: &report)
            case .file, .folder:
                launchPath(item, report: &report)
            case .url:
                launchURL(item, report: &report)
            }
        }
    }

    private func launchApp(_ item: SessionItem, report: inout LaunchReport) {
        guard let appPath = item.appPath ?? optionalPath(from: item.value) else {
            report.failures.append((item, "Missing app path"))
            return
        }

        let appURL = URL(fileURLWithPath: appPath)
        guard FileManager.default.fileExists(atPath: appURL.path) else {
            report.failures.append((item, "App missing at \(appURL.path)"))
            return
        }

        let config = NSWorkspace.OpenConfiguration()
        workspace.openApplication(at: appURL, configuration: config) { _, error in
            if let error {
                self.logger.error("App launch failed: \(item.displayName) :: \(error.localizedDescription)")
            }
        }
        report.successes.append(item)
    }

    private func launchPath(_ item: SessionItem, report: inout LaunchReport) {
        let path = item.value
        guard FileManager.default.fileExists(atPath: path) else {
            report.failures.append((item, "Path missing: \(path)"))
            return
        }

        let opened = workspace.open(URL(fileURLWithPath: path))
        if opened {
            report.successes.append(item)
        } else {
            report.failures.append((item, "NSWorkspace.open returned false"))
        }
    }

    private func launchURL(_ item: SessionItem, report: inout LaunchReport) {
        guard let normalized = URLNormalizer.normalize(item.value), let url = URL(string: normalized) else {
            report.failures.append((item, "Invalid URL: \(item.value)"))
            return
        }

        let opened = workspace.open(url)
        if opened {
            report.successes.append(item)
        } else {
            report.failures.append((item, "NSWorkspace.open returned false"))
        }
    }

    private func dedupe(items: [SessionItem]) -> [SessionItem] {
        var seen = Set<String>()
        var deduped: [SessionItem] = []

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

            if seen.contains(key) { continue }
            seen.insert(key)
            deduped.append(item)
        }

        return deduped
    }

    private func optionalPath(from value: String) -> String? {
        if value.hasPrefix("/") { return value }
        return nil
    }
}
