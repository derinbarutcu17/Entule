import Foundation

final class FinderDetector: DetectorProtocol {
    let name = "FinderDetector"

    func detect() async -> [SessionItem] {
        let script = #"""
        tell application "Finder"
            set outputLines to {}
            try
                repeat with w in windows
                    try
                        set p to POSIX path of (target of w as alias)
                        set end of outputLines to p
                    end try
                end repeat
            end try
            return outputLines as string
        end tell
        """#

        guard let output = AppleScriptRunner.run(script: script), !output.isEmpty else {
            return []
        }

        let parts = output
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return parts.map {
            SessionItem(
                kind: .folder,
                displayName: URL(fileURLWithPath: $0).lastPathComponent,
                value: $0,
                source: "detected-finder",
                isSelected: true
            )
        }
    }
}
