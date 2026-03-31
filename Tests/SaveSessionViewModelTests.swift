import XCTest
@testable import Entule

@MainActor
final class SaveSessionViewModelTests: XCTestCase {
    func testShouldConfirmEmptySelectionWhenNoItemsSelected() {
        let viewModel = SaveSessionViewModel()
        viewModel.items = [
            SessionItem(kind: .url, displayName: "Example", value: "https://example.com", source: "manual", isSelected: false)
        ]

        XCTAssertTrue(viewModel.shouldConfirmEmptySelection())
    }

    func testShouldNotConfirmEmptySelectionWhenAtLeastOneSelected() {
        let viewModel = SaveSessionViewModel()
        viewModel.items = [
            SessionItem(kind: .url, displayName: "Example", value: "https://example.com", source: "manual", isSelected: true)
        ]

        XCTAssertFalse(viewModel.shouldConfirmEmptySelection())
    }
}
