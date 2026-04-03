import XCTest
@testable import Entule

final class AppShellViewModelTests: XCTestCase {
    @MainActor
    func testNavigationStateTransitions() {
        let viewModel = AppShellViewModel()
        
        XCTAssertEqual(viewModel.activeSection, .home)
        XCTAssertEqual(viewModel.statusLine, "Ready")
        
        viewModel.openPresets()
        XCTAssertEqual(viewModel.activeSection, .presets)
        XCTAssertEqual(viewModel.statusLine, "Presets")
        
        viewModel.openSettings()
        XCTAssertEqual(viewModel.activeSection, .settings)
        XCTAssertEqual(viewModel.statusLine, "Settings")
        
        viewModel.showSaveSession()
        XCTAssertEqual(viewModel.activeSection, .saveSession)
        XCTAssertEqual(viewModel.statusLine, "Save session")
        
        viewModel.inspectCheckpoint()
        XCTAssertEqual(viewModel.activeSection, .inspectCheckpoint)
        XCTAssertEqual(viewModel.statusLine, "Inspect checkpoint")
        
        viewModel.showHome()
        XCTAssertEqual(viewModel.activeSection, .home)
        XCTAssertEqual(viewModel.statusLine, "Ready")
    }
}
