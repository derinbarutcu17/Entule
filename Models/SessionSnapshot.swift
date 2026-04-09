import Foundation

struct SessionSnapshot: Identifiable, Codable {
    var id: UUID
    var note: String
    var items: [SessionItem]
    var shortcutName: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        note: String,
        items: [SessionItem],
        shortcutName: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.note = note
        self.items = items
        self.shortcutName = shortcutName
        self.createdAt = createdAt
    }

    var hasUserProvidedName: Bool {
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        return trimmed != createdAt.formatted(date: .abbreviated, time: .shortened)
    }
}
