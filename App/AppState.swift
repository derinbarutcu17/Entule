import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published var model: AppStateModel = .empty

    let environment: AppEnvironment

    init(environment: AppEnvironment = .live) {
        self.environment = environment
    }

    func load() {
        do {
            model = try environment.store.loadState()
        } catch {
            environment.logger.error("Load state failed: \(error.localizedDescription)")
            model = .empty
        }
    }

    func save() {
        do {
            try environment.store.saveState(model)
        } catch {
            environment.logger.error("Save state failed: \(error.localizedDescription)")
        }
    }
}
