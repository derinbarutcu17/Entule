import XCTest
@testable import Entule

@MainActor
final class WorkspaceViewModelTests: XCTestCase {
    func testResumeLastSnapshotUsesSelectedSubset() async {
        let snapshotItems = [
            SessionItem(kind: .app, displayName: "A", value: "a", source: "manual"),
            SessionItem(kind: .app, displayName: "B", value: "b", source: "manual"),
            SessionItem(kind: .app, displayName: "C", value: "c", source: "manual")
        ]
        let launcher = MockLauncher()
        let appState = AppState(
            environment: AppEnvironment(
                store: InMemoryStore(model: AppStateModel(presets: [], lastSnapshot: SessionSnapshot(note: "", items: snapshotItems), schemaVersion: AppStateModel.currentSchemaVersion)),
                launcher: launcher,
                detectionCoordinator: DetectionCoordinator(),
                logger: .shared
            )
        )
        let viewModel = WorkspaceViewModel(appState: appState)
        viewModel.reload()

        let selected = Set([snapshotItems[0].id, snapshotItems[2].id])
        let report = await viewModel.resumeLastSnapshot(selectedItemIDs: selected)

        XCTAssertEqual(launcher.lastLaunchedItems.map(\.id), [snapshotItems[0].id, snapshotItems[2].id])
        XCTAssertEqual(report?.attemptedCount, 2)
    }

    func testResumeLastSnapshotWithEmptySelectionReturnsEmptyReport() async {
        let item = SessionItem(kind: .app, displayName: "A", value: "a", source: "manual")
        let launcher = MockLauncher()
        let appState = AppState(
            environment: AppEnvironment(
                store: InMemoryStore(model: AppStateModel(presets: [], lastSnapshot: SessionSnapshot(note: "", items: [item]), schemaVersion: AppStateModel.currentSchemaVersion)),
                launcher: launcher,
                detectionCoordinator: DetectionCoordinator(),
                logger: .shared
            )
        )
        let viewModel = WorkspaceViewModel(appState: appState)
        viewModel.reload()

        let report = await viewModel.resumeLastSnapshot(selectedItemIDs: [])

        XCTAssertEqual(report?.attemptedCount, 0)
        XCTAssertTrue(launcher.lastLaunchedItems.isEmpty)
    }
}

private final class MockLauncher: Launcher {
    var lastLaunchedItems: [SessionItem] = []

    func launch(items: [SessionItem], shortcutName: String?, dryRun: Bool) async -> LaunchReport {
        lastLaunchedItems = items
        return LaunchReport(attemptedItems: items, successes: items, failures: [], skipped: [], shortcutResult: nil)
    }
}

private final class InMemoryStore: Store {
    var model: AppStateModel

    init(model: AppStateModel) {
        self.model = model
    }

    func loadState() throws -> AppStateModel { model }

    func saveState(_ state: AppStateModel) throws {
        model = state
    }

    func mutate(_ transform: (inout AppStateModel) -> Void) throws -> AppStateModel {
        transform(&model)
        return model
    }

    func resetState() throws {
        model = .empty
    }
}
