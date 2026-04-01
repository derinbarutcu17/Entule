import XCTest
@testable import Entule

@MainActor
final class MenuBarViewModelTests: XCTestCase {
    func testSaveSnapshotPersistsLastSnapshot() async throws {
        let store = InMemoryStore()
        let launcher = RecordingLauncher()
        let environment = AppEnvironment(
            store: store,
            launcher: launcher,
            detectionCoordinator: DetectionCoordinator(detectors: []),
            logger: .shared
        )
        let appState = AppState(environment: environment)
        let viewModel = MenuBarViewModel(appState: appState)
        viewModel.reload()

        let snapshot = SessionSnapshot(
            note: "Test note",
            items: [
                SessionItem(kind: .url, displayName: "OpenAI", value: "https://openai.com", source: "manual")
            ]
        )

        viewModel.saveSnapshot(snapshot)

        XCTAssertEqual(viewModel.currentModel.lastSnapshot?.note, "Test note")
        XCTAssertEqual(viewModel.lastSnapshot?.items.count, 1)
        XCTAssertEqual(try store.loadState().lastSnapshot?.note, "Test note")
    }

    func testResumeLastSnapshotUsesLauncherWithSavedItems() async throws {
        let store = InMemoryStore()
        let launcher = RecordingLauncher()
        let environment = AppEnvironment(
            store: store,
            launcher: launcher,
            detectionCoordinator: DetectionCoordinator(detectors: []),
            logger: .shared
        )
        let appState = AppState(environment: environment)
        appState.model.lastSnapshot = SessionSnapshot(
            note: "Resume",
            items: [
                SessionItem(kind: .url, displayName: "Example", value: "https://example.com", source: "manual")
            ]
        )
        try store.saveState(appState.model)

        let viewModel = MenuBarViewModel(appState: appState)
        viewModel.reload()

        let report = await viewModel.resumeLastSnapshot()

        XCTAssertNotNil(report)
        XCTAssertEqual(launcher.launchedItems.first?.count, 1)
        XCTAssertEqual(launcher.launchedItems.first?.first?.displayName, "Example")
    }
}

private final class InMemoryStore: Store {
    private var state = AppStateModel.empty

    func loadState() throws -> AppStateModel {
        state
    }

    func saveState(_ state: AppStateModel) throws {
        self.state = state
    }

    func mutate(_ transform: (inout AppStateModel) -> Void) throws -> AppStateModel {
        transform(&state)
        return state
    }

    func resetState() throws {
        state = .empty
    }
}

private final class RecordingLauncher: Launcher {
    var launchedItems: [[SessionItem]] = []

    func launch(items: [SessionItem], shortcutName: String?, dryRun: Bool) async -> LaunchReport {
        launchedItems.append(items)
        var report = LaunchReport()
        report.attemptedItems = items
        report.successes = items
        return report
    }
}
