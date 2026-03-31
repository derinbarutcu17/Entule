import Foundation

struct LaunchIssue {
    var item: SessionItem
    var reason: String
}

struct LaunchReport {
    var attemptedItems: [SessionItem] = []
    var successes: [SessionItem] = []
    var failures: [LaunchIssue] = []
    var skipped: [LaunchIssue] = []
    var shortcutResult: ShortcutExecutionResult?

    var attemptedCount: Int { attemptedItems.count }
    var succeededCount: Int { successes.count }
    var failedCount: Int { failures.count }
    var skippedCount: Int { skipped.count }

    var summaryLine: String {
        "Attempted \(attemptedCount), succeeded \(succeededCount), failed \(failedCount), skipped \(skippedCount)"
    }
}

protocol Launcher {
    func launch(items: [SessionItem], shortcutName: String?, dryRun: Bool) async -> LaunchReport
}
