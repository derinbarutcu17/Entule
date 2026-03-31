import XCTest
@testable import Entule

final class LauncherTests: XCTestCase {
    func testDryRunReturnsSuccessesAndSkippedDuplicates() async {
        let launcher = NSWorkspaceLauncher()
        let items = [
            SessionItem(kind: .url, displayName: "Example", value: "example.com", source: "manual", isSelected: true),
            SessionItem(kind: .url, displayName: "Example Duplicate", value: "https://example.com/", source: "manual", isSelected: true)
        ]

        let report = await launcher.launch(items: items, shortcutName: nil, dryRun: true)
        XCTAssertEqual(report.attemptedCount, 1)
        XCTAssertEqual(report.succeededCount, 1)
        XCTAssertEqual(report.skippedCount, 1)
        XCTAssertEqual(report.failedCount, 0)
        XCTAssertTrue(report.summaryLine.contains("Attempted 1"))
    }
}
