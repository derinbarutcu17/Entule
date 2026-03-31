import Foundation

final class DetectionCoordinator {
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
        var errors: [String] = []

        await withTaskGroup(of: (String, [SessionItem]?).self) { group in
            for detector in detectors {
                group.addTask {
                    let items = await detector.detect()
                    return (detector.name, items)
                }
            }

            for await (name, items) in group {
                if let items {
                    merged.append(contentsOf: items)
                } else {
                    errors.append("\(name) returned no result")
                }
            }
        }

        let deduped = dedupe(merged)
        logger.info("Detection finished: \(deduped.count) items")

        return DetectionResult(items: deduped, errors: errors, startedAt: start, completedAt: Date())
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
}
