import Foundation

final class JSONStore: Store {
    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let logger: Logger

    init(fileManager: FileManager = .default, logger: Logger = .shared) {
        self.fileManager = fileManager
        self.logger = logger

        encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func loadState() throws -> AppStateModel {
        let stateURL = try FilePaths.stateFileURL(fileManager: fileManager)
        guard fileManager.fileExists(atPath: stateURL.path) else {
            do {
                if let migrated = try migrateLegacyStateIfAvailable() {
                    return migrated
                }
            } catch {
                logger.error("Legacy state migration failed: \(error.localizedDescription)")
            }
            let initial = AppStateModel.empty
            try saveState(initial)
            return initial
        }

        let data = try Data(contentsOf: stateURL)
        var state = try decoder.decode(AppStateModel.self, from: data)

        if state.schemaVersion <= 0 {
            state.schemaVersion = AppStateModel.currentSchemaVersion
        }

        return state
    }

    func saveState(_ state: AppStateModel) throws {
        let stateURL = try FilePaths.stateFileURL(fileManager: fileManager)
        var copy = state
        copy.schemaVersion = AppStateModel.currentSchemaVersion
        let data = try encoder.encode(copy)

        let tempURL = stateURL.deletingLastPathComponent()
            .appendingPathComponent("state.tmp.\(UUID().uuidString)")

        try data.write(to: tempURL, options: .atomic)

        if fileManager.fileExists(atPath: stateURL.path) {
            _ = try fileManager.replaceItemAt(stateURL, withItemAt: tempURL)
        } else {
            try fileManager.moveItem(at: tempURL, to: stateURL)
        }

        logger.info("State saved to \(stateURL.path)")
    }

    func mutate(_ transform: (inout AppStateModel) -> Void) throws -> AppStateModel {
        var state = try loadState()
        transform(&state)
        try saveState(state)
        return state
    }

    func resetState() throws {
        let appDirectory = try FilePaths.applicationSupportDirectory(fileManager: fileManager)
        if fileManager.fileExists(atPath: appDirectory.path) {
            try fileManager.removeItem(at: appDirectory)
        }
        try saveState(.empty)
        logger.info("State reset in \(appDirectory.path)")
    }

    private func migrateLegacyStateIfAvailable() throws -> AppStateModel? {
        let legacyURL = try FilePaths.legacyStateFileURL(fileManager: fileManager)
        guard fileManager.fileExists(atPath: legacyURL.path) else {
            return nil
        }

        let legacyData = try Data(contentsOf: legacyURL)
        var legacyState = try decoder.decode(AppStateModel.self, from: legacyData)
        if legacyState.schemaVersion <= 0 {
            legacyState.schemaVersion = AppStateModel.currentSchemaVersion
        }

        try saveState(legacyState)
        logger.info("Migrated legacy WorkCheckpoint state from \(legacyURL.path)")
        return legacyState
    }
}
