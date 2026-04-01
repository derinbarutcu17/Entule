import Foundation

protocol ProcessRunning {
    @discardableResult
    func run(_ launchPath: String, arguments: [String]) -> Int32
}

struct ProcessRunner: ProcessRunning {
    @discardableResult
    func run(_ launchPath: String, arguments: [String]) -> Int32 {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: launchPath)
        process.arguments = arguments

        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus
        } catch {
            return 1
        }
    }
}

struct FallbackLaunchCommand: Equatable {
    var launchPath: String
    var arguments: [String]
}

struct FallbackAppLauncher {
    let runner: ProcessRunning

    init(runner: ProcessRunning = ProcessRunner()) {
        self.runner = runner
    }

    func command(for item: SessionItem, resolvedAppURL: URL) -> FallbackLaunchCommand {
        if BundleAppResolver.bundleIdentifier(forAppPath: resolvedAppURL.path) != nil {
            return FallbackLaunchCommand(
                launchPath: "/usr/bin/open",
                arguments: ["-a", resolvedAppURL.path]
            )
        }

        if looksLikeBundleIdentifier(item.value) {
            return FallbackLaunchCommand(
                launchPath: "/usr/bin/open",
                arguments: ["-b", item.value]
            )
        }

        return FallbackLaunchCommand(
            launchPath: "/usr/bin/open",
            arguments: ["-a", resolvedAppURL.path]
        )
    }

    func launch(item: SessionItem, resolvedAppURL: URL) -> Bool {
        let command = command(for: item, resolvedAppURL: resolvedAppURL)
        return runner.run(command.launchPath, arguments: command.arguments) == 0
    }

    private func looksLikeBundleIdentifier(_ value: String) -> Bool {
        !value.contains("/") && value.contains(".")
    }
}
