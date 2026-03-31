import Foundation

enum DetectorStatus: String, Codable {
    case success
    case notRunning
    case unavailable
    case warning
    case failed
}

struct DetectorOutput: Codable {
    var detectorName: String
    var items: [SessionItem]
    var notes: [String]
    var warnings: [String]
    var status: DetectorStatus
}

struct DetectionResult: Codable {
    var items: [SessionItem]
    var notes: [String]
    var warnings: [String]
    var detectorOutputs: [DetectorOutput]
    var startedAt: Date
    var completedAt: Date
}
