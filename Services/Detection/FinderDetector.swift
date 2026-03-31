import Foundation

final class FinderDetector: DetectorProtocol {
    let name = "FinderDetector"

    func detect() async -> DetectorOutput {
        let script = #"""
        tell application "Finder"
            if not running then return "__NOT_RUNNING__"
            set rs to ASCII character 30
            set outputRows to {}
            repeat with w in windows
                try
                    set p to POSIX path of (target of w as alias)
                    set end of outputRows to p
                end try
            end repeat
            if (count of outputRows) is 0 then return ""
            set AppleScript's text item delimiters to rs
            set outText to outputRows as text
            set AppleScript's text item delimiters to ""
            return outText
        end tell
        """#

        let execution = AppleScriptRunner.run(script: script)
        if !execution.succeeded {
            let reason = execution.errorOutput.isEmpty ? "unknown osascript error" : execution.errorOutput
            if isPermissionIssue(reason) {
                return DetectorOutput(
                    detectorName: name,
                    items: [],
                    notes: ["Finder automation permission missing"],
                    warnings: [],
                    status: .unavailable
                )
            }

            return DetectorOutput(
                detectorName: name,
                items: [],
                notes: [],
                warnings: ["Finder detection failed: \(reason)"],
                status: .failed
            )
        }

        if execution.output == "__NOT_RUNNING__" {
            return DetectorOutput(
                detectorName: name,
                items: [],
                notes: ["Finder not running"],
                warnings: [],
                status: .notRunning
            )
        }

        let paths = DetectionParsing.parseFinderPaths(execution.output)
        let items = paths.map {
            SessionItem(
                kind: .folder,
                displayName: URL(fileURLWithPath: $0).lastPathComponent,
                value: $0,
                source: "detected-finder",
                isSelected: true
            )
        }

        return DetectorOutput(
            detectorName: name,
            items: items,
            notes: [],
            warnings: [],
            status: .success
        )
    }

    private func isPermissionIssue(_ text: String) -> Bool {
        let lower = text.lowercased()
        return lower.contains("not authorized") || lower.contains("-1743") || lower.contains("automation")
    }
}
