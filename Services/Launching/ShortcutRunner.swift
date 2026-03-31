import Foundation

struct ShortcutExecutionResult {
    var name: String
    var succeeded: Bool
    var output: String
    var errorOutput: String
    var exitCode: Int32
}

final class ShortcutRunner {
    private let logger: Logger

    init(logger: Logger = .shared) {
        self.logger = logger
    }

    func run(name: String, timeout: TimeInterval = 20) -> ShortcutExecutionResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/shortcuts")
        process.arguments = ["run", name]

        let outPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = errPipe

        do {
            try process.run()
        } catch {
            return ShortcutExecutionResult(
                name: name,
                succeeded: false,
                output: "",
                errorOutput: error.localizedDescription,
                exitCode: -1
            )
        }

        let deadline = Date().addingTimeInterval(timeout)
        while process.isRunning && Date() < deadline {
            Thread.sleep(forTimeInterval: 0.1)
        }

        if process.isRunning {
            process.terminate()
            return ShortcutExecutionResult(
                name: name,
                succeeded: false,
                output: "",
                errorOutput: "Timed out after \(timeout)s",
                exitCode: -2
            )
        }

        let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
        let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
        let out = String(data: outData, encoding: .utf8) ?? ""
        let err = String(data: errData, encoding: .utf8) ?? ""

        let result = ShortcutExecutionResult(
            name: name,
            succeeded: process.terminationStatus == 0,
            output: out,
            errorOutput: err,
            exitCode: process.terminationStatus
        )

        if result.succeeded {
            logger.info("Shortcut succeeded: \(name)")
        } else {
            logger.error("Shortcut failed: \(name) :: \(result.errorOutput)")
        }

        return result
    }
}
