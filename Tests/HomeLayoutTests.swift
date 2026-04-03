import XCTest
@testable import Entule

final class HomeLayoutTests: XCTestCase {
    func testWideLayoutFramesStayWithinBoundsAndDoNotOverlap() {
        let size = CGSize(width: 1320, height: 820)
        let frames = HomeLayout.make(in: size)

        XCTAssertEqual(frames.tier, .wide)
        assert(frames: frames, within: size)
        XCTAssertFalse(frames.resumeFrame.intersects(frames.previewFrame))
        XCTAssertFalse(frames.previewFrame.intersects(frames.inspectFrame))
    }

    func testMediumLayoutFramesStayWithinBoundsAndDoNotOverlap() {
        let size = CGSize(width: 1080, height: 700)
        let frames = HomeLayout.make(in: size)

        XCTAssertEqual(frames.tier, .medium)
        assert(frames: frames, within: size)
        XCTAssertFalse(frames.resumeFrame.intersects(frames.previewFrame))
        XCTAssertFalse(frames.previewFrame.intersects(frames.inspectFrame))
    }

    func testCompactLayoutFramesStayWithinBoundsAndDoNotOverlap() {
        let size = CGSize(width: 920, height: 640)
        let frames = HomeLayout.make(in: size)

        XCTAssertEqual(frames.tier, .compact)
        assert(frames: frames, within: size)
        XCTAssertFalse(frames.resumeFrame.intersects(frames.previewFrame))
        XCTAssertFalse(frames.resumeFrame.intersects(frames.inspectFrame))
    }

    private func assert(frames: HomeLayoutFrames, within size: CGSize, file: StaticString = #filePath, line: UInt = #line) {
        let bounds = CGRect(origin: .zero, size: size)
        [frames.saveFrame, frames.resumeFrame, frames.previewFrame, frames.inspectFrame, frames.utilityFrame].forEach { frame in
            XCTAssertTrue(bounds.contains(frame), "Frame \(frame) escaped bounds \(bounds)", file: file, line: line)
        }
    }
}
