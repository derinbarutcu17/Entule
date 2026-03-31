import Foundation

struct DetectorOutput: Codable {
    var detectorName: String
    var items: [SessionItem]
    var warnings: [String]
    var failed: Bool
}

struct DetectionResult: Codable {
    var items: [SessionItem]
    var warnings: [String]
    var detectorOutputs: [DetectorOutput]
    var startedAt: Date
    var completedAt: Date
}
