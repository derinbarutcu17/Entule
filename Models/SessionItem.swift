import Foundation

enum SessionItemKind: String, Codable, CaseIterable {
    case app
    case file
    case folder
    case url
}

struct SessionItem: Identifiable, Codable, Hashable {
    var id: UUID
    var kind: SessionItemKind
    var displayName: String
    var value: String
    var appPath: String?
    var iconHint: String?
    var source: String
    var isSelected: Bool

    init(
        id: UUID = UUID(),
        kind: SessionItemKind,
        displayName: String,
        value: String,
        appPath: String? = nil,
        iconHint: String? = nil,
        source: String,
        isSelected: Bool = true
    ) {
        self.id = id
        self.kind = kind
        self.displayName = displayName
        self.value = value
        self.appPath = appPath
        self.iconHint = iconHint
        self.source = source
        self.isSelected = isSelected
    }
}
