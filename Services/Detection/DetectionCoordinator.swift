import Foundation

final class DetectionCoordinator {
    static let supportedDetectorNames = [
        "AppDetector",
        "FinderDetector",
        "SafariDetector",
        "ChromeDetector"
    ]

    private let detectors: [DetectorProtocol]
    private let logger: Logger

    init(detectors: [DetectorProtocol], logger: Logger = .shared) {
        self.detectors = detectors
        self.logger = logger
    }

    convenience init(logger: Logger = .shared) {
        self.init(
            detectors: [
                AppDetector(),
                FinderDetector(),
                SafariDetector(),
                ChromeDetector()
            ],
            logger: logger
        )
    }

    func detectAll() async -> DetectionResult {
        let start = Date()
        var merged: [SessionItem] = []
        var allNotes: [String] = []
        var allWarnings: [String] = []
        var detectorOutputs: [DetectorOutput] = []

        await withTaskGroup(of: DetectorOutput.self) { group in
            for detector in detectors {
                group.addTask {
                    await detector.detect()
                }
            }

            for await output in group {
                merged.append(contentsOf: output.items)
                allNotes.append(contentsOf: output.notes)
                allWarnings.append(contentsOf: output.warnings)
                detectorOutputs.append(output)
            }
        }

        let deduped = dedupe(merged)
        logger.info("Detection finished: \(deduped.count) items, \(allWarnings.count) warnings")

        return DetectionResult(
            items: deduped,
            notes: unique(allNotes),
            warnings: unique(allWarnings),
            detectorOutputs: detectorOutputs.sorted(by: { $0.detectorName < $1.detectorName }),
            startedAt: start,
            completedAt: Date()
        )
    }

    private func dedupe(_ items: [SessionItem]) -> [SessionItem] {
        var seen = Set<String>()
        var result: [SessionItem] = []

        for item in items {
            let key: String
            switch item.kind {
            case .app:
                key = "app::\((item.appPath ?? item.value).lowercased())"
            case .file:
                key = "file::\(item.value)"
            case .folder:
                key = "folder::\(item.value)"
            case .url:
                key = "url::\(URLNormalizer.normalize(item.value) ?? item.value)"
            }
            if seen.contains(key) { continue }
            seen.insert(key)
            result.append(item)
        }

        return result
    }

    private func unique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values.filter { value in
            if seen.contains(value) { return false }
            seen.insert(value)
            return true
        }
    }
}
