import AppKit
import Foundation
import XCTest
@testable import Entule

final class AppOpenAwaiterTests: XCTestCase {
    func testOpenApplicationReturnsSuccess() async {
        let opener = MockAppOpener(mode: .success)
        let awaiter = AppOpenAwaiter(opener: opener)

        let result = await awaiter.openApplication(at: URL(fileURLWithPath: "/Applications/Safari.app"))
        switch result {
        case .success:
            XCTAssertTrue(true)
        case let .failure(reason):
            XCTFail("Expected success, got failure: \(reason)")
        }
    }

    func testOpenApplicationReturnsFailureFromCallbackError() async {
        let opener = MockAppOpener(mode: .error("boom"))
        let awaiter = AppOpenAwaiter(opener: opener)

        let result = await awaiter.openApplication(at: URL(fileURLWithPath: "/Applications/Safari.app"))
        switch result {
        case .success:
            XCTFail("Expected failure")
        case let .failure(error):
            XCTAssertTrue(error.message.contains("boom"))
        }
    }

    func testOpenApplicationReturnsFailureWhenNoRunningAppReturned() async {
        let opener = MockAppOpener(mode: .noApp)
        let awaiter = AppOpenAwaiter(opener: opener)

        let result = await awaiter.openApplication(at: URL(fileURLWithPath: "/Applications/Safari.app"))
        switch result {
        case .success:
            XCTFail("Expected failure")
        case let .failure(error):
            XCTAssertTrue(error.message.contains("no running app"))
        }
    }
}

private final class MockAppOpener: AppOpening {
    enum Mode {
        case success
        case error(String)
        case noApp
    }

    private let mode: Mode

    init(mode: Mode) {
        self.mode = mode
    }

    func openApplication(
        at applicationURL: URL,
        configuration: NSWorkspace.OpenConfiguration,
        completion: @escaping @Sendable (NSRunningApplication?, Error?) -> Void
    ) {
        switch mode {
        case .success:
            completion(NSRunningApplication.current, nil)
        case let .error(message):
            completion(nil, NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: message]))
        case .noApp:
            completion(nil, nil)
        }
    }
}
