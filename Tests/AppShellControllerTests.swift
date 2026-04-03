import XCTest
@testable import Entule

final class AppShellControllerTests: XCTestCase {
    @MainActor
    func testShowMainWindowCreatesHostingControllerOnceAndReusesIt() {
        let appState = AppState()
        let workspaceViewModel = WorkspaceViewModel(appState: appState)
        let shellViewModel = AppShellViewModel()
        let controller = AppShellController(
            appShellViewModel: shellViewModel,
            workspaceViewModel: workspaceViewModel
        )

        controller.showMainWindow(section: .home)
        XCTAssertTrue(controller.testOnlyHasPrimaryHostingController())

        controller.showMainWindow(section: .settings)
        XCTAssertTrue(controller.testOnlyHasPrimaryHostingController())
        XCTAssertEqual(shellViewModel.activeSection, .settings)
    }
}
