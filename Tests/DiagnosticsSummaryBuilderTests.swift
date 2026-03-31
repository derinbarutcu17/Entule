import Foundation
import XCTest
@testable import Entule

final class DiagnosticsSummaryBuilderTests: XCTestCase {
    func testSummaryContainsCoreFields() {
        let model = AppStateModel(
            presets: [Preset(name: "A", items: [])],
            lastSnapshot: SessionSnapshot(note: "n", items: [SessionItem(kind: .url, displayName: "x", value: "https://example.com", source: "manual", isSelected: true)]),
            schemaVersion: 1
        )

        let text = DiagnosticsSummaryBuilder.build(
            model: model,
            stateFilePath: "/tmp/state.json",
            legacyStateExists: true,
            supportedDetectors: ["AppDetector", "SafariDetector"]
        )

        XCTAssertTrue(text.contains("Preset count: 1"))
        XCTAssertTrue(text.contains("Last snapshot exists: yes"))
        XCTAssertTrue(text.contains("Last snapshot item count: 1"))
        XCTAssertTrue(text.contains("State file: /tmp/state.json"))
        XCTAssertTrue(text.contains("Legacy WorkCheckpoint state exists: yes"))
        XCTAssertTrue(text.contains("Supported detectors: AppDetector, SafariDetector"))
    }
}
