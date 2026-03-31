import Foundation

final class ChromeDetector: DetectorProtocol {
    let name = "ChromeDetector"

    func detect() async -> DetectorOutput {
        let script = #"""
        tell application "Google Chrome"
            if not running then return "__NOT_RUNNING__"
            set rs to ASCII character 30
            set fs to ASCII character 31
            set outputRows to {}
            repeat with w in windows
                try
                    set t to active tab of w
                    set rowText to ((title of t) & fs & (URL of t))
                    set end of outputRows to rowText
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
                warnings: ["Chrome detection failed: \(execution.errorOutput.isEmpty ? "unknown osascript error" : execution.errorOutput)"],
                failed: true
            )
        }

        if execution.output == "__NOT_RUNNING__" {
            return DetectorOutput(detectorName: name, items: [], warnings: ["Google Chrome not running"], failed: false)
        }

        var warnings: [String] = []
        let items = DetectionParsing.parseBrowserRows(execution.output).compactMap { row -> SessionItem? in
            guard let normalized = URLNormalizer.normalize(row.url) else {
                warnings.append("Chrome row skipped due to invalid URL")
                return nil
            }
            return SessionItem(
                kind: .url,
                displayName: row.title.isEmpty ? normalized : row.title,
                value: normalized,
                source: "detected-chrome",
                isSelected: true
            )
        }

        return DetectorOutput(detectorName: name, items: items, warnings: warnings, failed: false)
    }
}
