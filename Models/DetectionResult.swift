import Foundation

struct DetectionResult: Codable {
    var items: [SessionItem]
    var errors: [String]
    var startedAt: Date
    var completedAt: Date
}
