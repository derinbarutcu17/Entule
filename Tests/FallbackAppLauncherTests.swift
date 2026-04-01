import XCTest
@testable import Entule

final class FallbackAppLauncherTests: XCTestCase {
    func testCommandUsesOpenAForAppPath() {
        let launcher = FallbackAppLauncher(runner: MockProcessRunner())
        let item = SessionItem(
            kind: .app,
            displayName: "Safari",
            value: "com.apple.Safari",
            appPath: "/Applications/Safari.app",
            source: "manual"
        )

        let command = launcher.command(
            for: item,
            resolvedAppURL: URL(fileURLWithPath: "/Applications/Safari.app")
        )

        XCTAssertEqual(command.launchPath, "/usr/bin/open")
        XCTAssertEqual(command.arguments, ["-a", "/Applications/Safari.app"])
    }

    func testLaunchReturnsFalseWhenRunnerFails() {
        let runner = MockProcessRunner(exitCode: 1)
        let launcher = FallbackAppLauncher(runner: runner)
        let item = SessionItem(
            kind: .app,
            displayName: "Telegram",
            value: "org.telegram.desktop",
            appPath: nil,
            source: "manual"
        )

        let succeeded = launcher.launch(
            item: item,
            resolvedAppURL: URL(fileURLWithPath: "/Applications/Telegram.app")
        )

        XCTAssertFalse(succeeded)
    }
}

private final class MockProcessRunner: ProcessRunning {
    let exitCode: Int32

    init(exitCode: Int32 = 0) {
        self.exitCode = exitCode
    }

    func run(_ launchPath: String, arguments: [String]) -> Int32 {
        exitCode
    }
}
