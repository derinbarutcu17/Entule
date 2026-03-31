import XCTest
@testable import WorkCheckpoint

final class DetectionNormalizationTests: XCTestCase {
    func testURLNormalization() {
        XCTAssertEqual(URLNormalizer.normalize("example.com"), "https://example.com/")
        XCTAssertEqual(URLNormalizer.normalize("HTTPS://EXAMPLE.COM/path"), "https://example.com/path")
        XCTAssertNil(URLNormalizer.normalize("not a url"))
    }

    func testDetectionMergeDedupe() async {
        let a = StaticDetector(name: "A", items: [
            SessionItem(kind: .url, displayName: "A", value: "example.com", source: "detected-safari", isSelected: true)
        ])
        let b = StaticDetector(name: "B", items: [
            SessionItem(kind: .url, displayName: "B", value: "https://example.com/", source: "detected-chrome", isSelected: true)
        ])

        let coordinator = DetectionCoordinator(detectors: [a, b])
        let result = await coordinator.detectAll()
        XCTAssertEqual(result.items.count, 1)
    }
}

struct StaticDetector: DetectorProtocol {
    let name: String
    let items: [SessionItem]

    func detect() async -> [SessionItem] {
        items
    }
}
