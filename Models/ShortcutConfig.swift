import Foundation

struct ShortcutConfig: Codable, Hashable {
    var name: String
    var timeoutSeconds: TimeInterval

    init(name: String, timeoutSeconds: TimeInterval = 15) {
        self.name = name
        self.timeoutSeconds = timeoutSeconds
    }
}
