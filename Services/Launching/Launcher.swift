import Foundation

struct LaunchReport {
    var successes: [SessionItem] = []
    var failures: [(item: SessionItem, reason: String)] = []
    var skipped: [(item: SessionItem, reason: String)] = []
    var shortcutResult: ShortcutExecutionResult?
}

protocol Launcher {
    func launch(items: [SessionItem], shortcutName: String?, dryRun: Bool) async -> LaunchReport
}
