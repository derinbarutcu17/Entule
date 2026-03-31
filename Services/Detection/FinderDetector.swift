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
            return DetectorOutput(
                detectorName: name,
                items: [],
                warnings: ["Finder detection failed: \(execution.errorOutput.isEmpty ? "unknown osascript error" : execution.errorOutput)"],
                failed: true
            )
        }

        if execution.output == "__NOT_RUNNING__" {
            return DetectorOutput(detectorName: name, items: [], warnings: ["Finder not running"], failed: false)
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

        return DetectorOutput(detectorName: name, items: items, warnings: [], failed: false)
    }
}
