import Foundation

struct AppStateModel: Codable {
    var presets: [Preset]
    var lastSnapshot: SessionSnapshot?
    var schemaVersion: Int

    static let currentSchemaVersion = 1

    static let empty = AppStateModel(
        presets: [],
        lastSnapshot: nil,
        schemaVersion: currentSchemaVersion
    )
}
