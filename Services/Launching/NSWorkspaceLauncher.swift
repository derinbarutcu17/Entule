import AppKit
import Foundation

final class NSWorkspaceLauncher: Launcher {
    private let workspace: NSWorkspace
    private let appLaunchResolver: AppLaunchResolver
    private let shortcutRunner: ShortcutRunner
    private let logger: Logger

    init(
        workspace: NSWorkspace = .shared,
        installedAppResolver: InstalledAppResolving? = nil,
        fileChecker: FileExistenceChecking = FileManager.default,
        shortcutRunner: ShortcutRunner = ShortcutRunner(),
        logger: Logger = .shared
    ) {
        self.workspace = workspace
        let resolver = installedAppResolver ?? NSWorkspaceInstalledAppResolver(workspace: workspace)
        self.appLaunchResolver = AppLaunchResolver(fileChecker: fileChecker, installedAppResolver: resolver)
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
                launchApp(item, report: &report)
            case .file, .folder:
                launchPath(item, report: &report)
            case .url:
                launchURL(item, report: &report)
            }
        }
    }

    private func launchApp(_ item: SessionItem, report: inout LaunchReport) {
        let resolution = appLaunchResolver.resolve(item: item)

        switch resolution {
        case let .resolved(appURL):
            let config = NSWorkspace.OpenConfiguration()
            workspace.openApplication(at: appURL, configuration: config) { _, error in
                if let error {
                    self.logger.error("App launch callback error: \(item.displayName) :: \(error.localizedDescription)")
                }
            }
            report.successes.append(item)
        case let .failed(reason):
            report.failures.append(LaunchIssue(item: item, reason: reason))
        }
    }

    private func launchPath(_ item: SessionItem, report: inout LaunchReport) {
        let path = item.value
        guard FileManager.default.fileExists(atPath: path) else {
            report.failures.append(LaunchIssue(item: item, reason: "Path missing: \(path)"))
            return
        }

        let opened = workspace.open(URL(fileURLWithPath: path))
        if opened {
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

        let opened = workspace.open(url)
        if opened {
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

}
