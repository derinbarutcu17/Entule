import Foundation

struct Preset: Identifiable, Codable {
    var id: UUID
    var name: String
    var items: [SessionItem]
    var shortcutName: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        items: [SessionItem],
        shortcutName: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.items = items
        self.shortcutName = shortcutName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
