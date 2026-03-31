import Foundation

final class SafariDetector: DetectorProtocol {
    let name = "SafariDetector"

    func detect() async -> [SessionItem] {
        let script = #"""
        tell application "Safari"
            if not running then return ""
            set outputLines to {}
            repeat with w in windows
                try
                    set t to current tab of w
                    set end of outputLines to ((name of t) & "|||" & (URL of t))
                end try
            end repeat
            return outputLines as string
        end tell
        """#

        guard let output = AppleScriptRunner.run(script: script), !output.isEmpty else {
            return []
        }

        let rows = output.split(separator: ",").map { String($0) }
        return rows.compactMap { row in
            let pair = row.split(separator: "|", omittingEmptySubsequences: false)
            let components = row.components(separatedBy: "|||")
            guard components.count >= 2 else { return nil }
            let title = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let url = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
            guard let normalized = URLNormalizer.normalize(url) else { return nil }
            _ = pair
            return SessionItem(
                kind: .url,
                displayName: title.isEmpty ? normalized : title,
                value: normalized,
                source: "detected-safari",
                isSelected: true
            )
        }
    }
}
