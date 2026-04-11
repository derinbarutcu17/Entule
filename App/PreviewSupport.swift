import Foundation
import SwiftUI

final class PreviewStore: Store {
    private var model: AppStateModel

    init(model: AppStateModel) {
        self.model = model
    }

    func loadState() throws -> AppStateModel {
        model
    }

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

struct PreviewLauncher: Launcher {
    func launch(items: [SessionItem], shortcutName: String?, dryRun: Bool) async -> LaunchReport {
        LaunchReport(attemptedItems: items, successes: items)
    }
}

enum PreviewFactory {
    static func makeAppStateModel(withSnapshot: Bool = true, manyItems: Bool = true) -> AppStateModel {
        let items = manyItems ? sampleItems : Array(sampleItems.prefix(2))
        let snapshot = withSnapshot ? SessionSnapshot(
            note: "Friday Product Sprint",
            items: items,
            shortcutName: nil,
            createdAt: Date().addingTimeInterval(-3600)
        ) : nil

        return AppStateModel(
            presets: samplePresets,
            lastSnapshot: snapshot,
            schemaVersion: AppStateModel.currentSchemaVersion
        )
    }

    @MainActor
    static func makeWorkspaceViewModel(withSnapshot: Bool = true, manyItems: Bool = true) -> WorkspaceViewModel {
        let environment = AppEnvironment(
            store: PreviewStore(model: makeAppStateModel(withSnapshot: withSnapshot, manyItems: manyItems)),
            launcher: PreviewLauncher(),
            detectionCoordinator: DetectionCoordinator(),
            logger: .shared
        )
        let appState = AppState(environment: environment)
        let viewModel = WorkspaceViewModel(appState: appState)
        viewModel.reload()
        return viewModel
    }

    @MainActor
    static func makeDashboard(section: AppSection = .home, withSnapshot: Bool = true, manyItems: Bool = true) -> some View {
        let shell = AppShellViewModel()
        shell.navigate(to: section)
        let workspace = makeWorkspaceViewModel(withSnapshot: withSnapshot, manyItems: manyItems)
        return EntuleDashboardView(appShellViewModel: shell, workspaceViewModel: workspace)
            .frame(width: AppWindowMetrics.defaultWindowWidth, height: AppWindowMetrics.defaultWindowHeight)
    }

    static let sampleItems: [SessionItem] = [
        SessionItem(kind: .app, displayName: "Codex", value: "Codex", source: "preview"),
        SessionItem(kind: .app, displayName: "WhatsApp", value: "WhatsApp", source: "preview"),
        SessionItem(kind: .url, displayName: "Linear Roadmap", value: "https://linear.app", source: "preview"),
        SessionItem(kind: .file, displayName: "Q2 Planning Notes", value: "/Users/derin/Documents/Q2 Planning Notes.md", source: "preview"),
        SessionItem(kind: .folder, displayName: "Entule Repo", value: "/Users/derin/Desktop/CODING/Entule", source: "preview")
    ]

    static let samplePresets: [Preset] = [
        Preset(name: "Daily Ops", items: Array(sampleItems.prefix(3))),
        Preset(name: "Product Review", items: Array(sampleItems.suffix(3)))
    ]
}

@available(macOS 14.0, *)
#Preview("Home · Default") {
    PreviewFactory.makeDashboard(section: .home)
}

@available(macOS 14.0, *)
#Preview("Home · Empty") {
    PreviewFactory.makeDashboard(section: .home, withSnapshot: false, manyItems: false)
}

@available(macOS 14.0, *)
#Preview("Settings") {
    PreviewFactory.makeDashboard(section: .settings)
}

@available(macOS 14.0, *)
#Preview("Presets") {
    PreviewFactory.makeDashboard(section: .presets)
}
