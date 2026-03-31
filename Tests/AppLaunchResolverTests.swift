import Foundation
import XCTest
@testable import Entule

final class AppLaunchResolverTests: XCTestCase {
    func testResolvePrefersExistingAppPath() {
        let path = "/Applications/Sample.app"
        let resolver = AppLaunchResolver(
            fileChecker: MockFileChecker(existing: [path]),
            installedAppResolver: MockInstalledAppResolver(result: nil)
        )

        let item = SessionItem(
            kind: .app,
            displayName: "Sample",
            value: "com.example.sample",
            appPath: path,
            source: "manual",
            isSelected: true
        )

        let result = resolver.resolve(item: item)
        switch result {
        case let .resolved(url):
            XCTAssertEqual(url.path, path)
        case let .failed(reason):
            XCTFail("Expected resolved path, got failure: \(reason)")
        }
    }

    func testResolveFallsBackToBundleIdentifier() {
        let fallbackPath = "/Applications/Fallback.app"
        let resolver = AppLaunchResolver(
            fileChecker: MockFileChecker(existing: [fallbackPath]),
            installedAppResolver: MockInstalledAppResolver(result: URL(fileURLWithPath: fallbackPath))
        )

        let item = SessionItem(
            kind: .app,
            displayName: "Fallback",
            value: "com.example.fallback",
            appPath: "/missing/app.app",
            source: "manual",
            isSelected: true
        )

        let result = resolver.resolve(item: item)
        switch result {
        case let .resolved(url):
            XCTAssertEqual(url.path, fallbackPath)
        case let .failed(reason):
            XCTFail("Expected bundle fallback resolve, got failure: \(reason)")
        }
    }

    func testResolveFailsWhenNoPathAndBundleLookupFails() {
        let resolver = AppLaunchResolver(
            fileChecker: MockFileChecker(existing: []),
            installedAppResolver: MockInstalledAppResolver(result: nil)
        )

        let item = SessionItem(
            kind: .app,
            displayName: "Missing",
            value: "com.example.missing",
            appPath: nil,
            source: "manual",
            isSelected: true
        )

        let result = resolver.resolve(item: item)
        switch result {
        case .resolved:
            XCTFail("Expected resolution failure")
        case let .failed(reason):
            XCTAssertTrue(reason.contains("Bundle lookup failed"))
        }
    }
}

private struct MockFileChecker: FileExistenceChecking {
    let existing: Set<String>

    init(existing: [String]) {
        self.existing = Set(existing)
    }

    func fileExists(atPath path: String) -> Bool {
        existing.contains(path)
    }
}

private struct MockInstalledAppResolver: InstalledAppResolving {
    let result: URL?

    func appURL(forBundleIdentifier bundleIdentifier: String) -> URL? {
        result
    }
}
