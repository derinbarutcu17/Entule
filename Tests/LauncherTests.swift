import XCTest
@testable import WorkCheckpoint

final class LauncherTests: XCTestCase {
    func testDryRunReturnsSuccesses() async {
        let launcher = NSWorkspaceLauncher()
        let items = [
            SessionItem(kind: .url, displayName: "Example", value: "example.com", source: "manual", isSelected: true),
            SessionItem(kind: .url, displayName: "Example Duplicate", value: "https://example.com/", source: "manual", isSelected: true)
        ]

        let report = await launcher.launch(items: items, shortcutName: nil, dryRun: true)
        XCTAssertEqual(report.successes.count, 1)
        XCTAssertTrue(report.failures.isEmpty)
    }
}
