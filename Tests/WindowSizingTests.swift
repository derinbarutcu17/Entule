import AppKit
import XCTest
@testable import Entule

@MainActor
final class WindowSizingTests: XCTestCase {
    func testExistingWindowIsExpandedToTargetMinimum() {
        let window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 320, height: 240),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )

        let controller = AppWindowController.shared
        controller.testOnlyEnforceMinimumSize(on: window, targetSize: NSSize(width: 760, height: 560))

        XCTAssertGreaterThanOrEqual(window.frame.width, 760)
        XCTAssertGreaterThanOrEqual(window.frame.height, 560)
        XCTAssertEqual(window.minSize.width, 760)
        XCTAssertEqual(window.minSize.height, 560)
    }
}
