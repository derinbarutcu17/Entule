import XCTest
@testable import Entule

final class DetectionNormalizationTests: XCTestCase {
    func testURLNormalization() {
        XCTAssertEqual(URLNormalizer.normalize("example.com"), "https://example.com/")
        XCTAssertEqual(URLNormalizer.normalize("HTTPS://EXAMPLE.COM/path"), "https://example.com/path")
        XCTAssertNil(URLNormalizer.normalize("not a url"))
    }

    func testDetectionMergeDedupe() async {
        let a = StaticDetector(name: "A", output: DetectorOutput(
            detectorName: "A",
            items: [SessionItem(kind: .url, displayName: "A", value: "example.com", source: "detected-safari", isSelected: true)],
            warnings: [],
            failed: false
        ))
        let b = StaticDetector(name: "B", output: DetectorOutput(
            detectorName: "B",
            items: [SessionItem(kind: .url, displayName: "B", value: "https://example.com/", source: "detected-chrome", isSelected: true)],
            warnings: [],
            failed: false
        ))

        let coordinator = DetectionCoordinator(detectors: [a, b])
        let result = await coordinator.detectAll()
        XCTAssertEqual(result.items.count, 1)
    }

    func testBrowserParsingWithControlSeparators() {
        let record = String(UnicodeScalar(30))
        let field = String(UnicodeScalar(31))
        let raw = "A title, with comma\(field)https://example.com/a,b\(record)B\(field)https://example.org"
        let rows = DetectionParsing.parseBrowserRows(raw)

        XCTAssertEqual(rows.count, 2)
        XCTAssertEqual(rows[0].title, "A title, with comma")
        XCTAssertEqual(rows[0].url, "https://example.com/a,b")
    }

    func testFinderParsingWithControlSeparators() {
        let record = String(UnicodeScalar(30))
        let raw = "/tmp/one,with,comma\(record)/tmp/two"
        let rows = DetectionParsing.parseFinderPaths(raw)

        XCTAssertEqual(rows.count, 2)
        XCTAssertEqual(rows[0], "/tmp/one,with,comma")
    }
}

struct StaticDetector: DetectorProtocol {
    let name: String
    let output: DetectorOutput

    func detect() async -> DetectorOutput {
        output
    }
}
