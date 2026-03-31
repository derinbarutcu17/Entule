import Foundation

struct AppleScriptExecutionResult {
    var output: String
    var errorOutput: String
    var exitCode: Int32

    var succeeded: Bool {
        exitCode == 0
    }
}

enum AppleScriptRunner {
    static func run(script: String) -> AppleScriptExecutionResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", script]

        let outPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = errPipe

        do {
            try process.run()
        } catch {
            return AppleScriptExecutionResult(
                output: "",
                errorOutput: error.localizedDescription,
                exitCode: -1
            )
        }

        process.waitUntilExit()

        let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
        let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
        return AppleScriptExecutionResult(
            output: String(data: outData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            errorOutput: String(data: errData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            exitCode: process.terminationStatus
        )
    }
}
