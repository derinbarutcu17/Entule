import XCTest
@testable import Entule

final class ModelTests: XCTestCase {
    func testSessionItemCodableRoundTrip() throws {
        let item = SessionItem(
            kind: .url,
            displayName: "Example",
            value: "https://example.com",
            source: "manual",
            isSelected: true
        )

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let data = try encoder.encode(item)
        let decoded = try decoder.decode(SessionItem.self, from: data)

        XCTAssertEqual(decoded, item)
    }

    func testAppStateModelDefaultSchema() {
        XCTAssertEqual(AppStateModel.empty.schemaVersion, AppStateModel.currentSchemaVersion)
        XCTAssertTrue(AppStateModel.empty.presets.isEmpty)
        XCTAssertNil(AppStateModel.empty.lastSnapshot)
    }
}
