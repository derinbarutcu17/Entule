import Foundation

enum AutomationAccessPrompter {
    struct PromptResult {
        let promptedAppName: String?
        let message: String
    }

    static func requestBrowserAutomationAccess() -> PromptResult {
        let probes: [(name: String, script: String)] = [
            (
                "Dia",
                #"""
                tell application "Dia"
                    if running then
                        try
                            return URL of active tab of front window
                        on error
                            return "__DIA_NO_TAB__"
                        end try
                    end if
                end tell
                """#
            ),
            (
                "Google Chrome",
                #"""
                tell application "Google Chrome"
                    if running then
                        try
                            return URL of active tab of front window
                        on error
                            return "__CHROME_NO_TAB__"
                        end try
                    end if
                end tell
                """#
            ),
            (
                "Safari",
                #"""
                tell application "Safari"
                    if running then
                        try
                            return URL of current tab of front window
                        on error
                            return "__SAFARI_NO_TAB__"
                        end try
                    end if
                end tell
                """#
            )
        ]

        var attemptedBrowsers: [String] = []
        var triggeredPrompt = false

        for probe in probes {
            let result = AppleScriptRunner.run(script: probe.script)
            if result.succeeded || isAutomationPermissionIssue(result.errorOutput) {
                attemptedBrowsers.append(probe.name)
                triggeredPrompt = true
            }
        }

        if triggeredPrompt {
            return PromptResult(
                promptedAppName: attemptedBrowsers.first,
                message: "Requested browser automation access across Entule-supported browsers (\(attemptedBrowsers.joined(separator: ", "))). If macOS did not show prompts, open Automation settings and enable Entule for your browsers."
            )
        }

        return PromptResult(
            promptedAppName: nil,
            message: "Could not trigger browser permission prompts automatically. Open Automation settings and enable Entule for your browsers (Dia, Chrome, Safari)."
        )
    }

    private static func isAutomationPermissionIssue(_ text: String) -> Bool {
        let lower = text.lowercased()
        return lower.contains("not authorized") || lower.contains("-1743") || lower.contains("automation")
    }
}
