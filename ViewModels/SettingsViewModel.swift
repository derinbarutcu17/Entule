import AppKit
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var feedbackMessage: String = ""

    private let workspaceViewModel: WorkspaceViewModel

    init(workspaceViewModel: WorkspaceViewModel) {
        self.workspaceViewModel = workspaceViewModel
    }

    var permissionsHint: String {
        PermissionsHelper.appleEventsHelpText()
    }

    var dataSummary: String {
        let presetCount = workspaceViewModel.currentModel.presets.count
        let presetLabel = presetCount == 1 ? "1 preset" : "\(presetCount) presets"

        if let snapshot = workspaceViewModel.lastSnapshot {
            let itemCount = snapshot.items.count
            let itemLabel = itemCount == 1 ? "1 saved item" : "\(itemCount) saved items"
            return "Entule currently stores \(presetLabel) and one recent checkpoint with \(itemLabel) on this Mac."
        }

        return "Entule currently stores \(presetLabel) locally on this Mac. No recent checkpoint is saved right now."
    }

    func openAutomationSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation") {
            NSWorkspace.shared.open(url)
            feedbackMessage = "Opened macOS Automation settings"
        } else {
            feedbackMessage = "Could not open macOS Automation settings"
        }
    }

    func requestBrowserAutomationAccess() {
        let result = AutomationAccessPrompter.requestBrowserAutomationAccess()
        feedbackMessage = result.message
    }

    func revealDataFolder() {
        do {
            let directory = try FilePaths.applicationSupportDirectory()
            NSWorkspace.shared.open(directory)
            feedbackMessage = "Opened Entule data folder"
        } catch {
            feedbackMessage = "Could not open Entule data folder"
        }
    }

    func clearLastSnapshot() {
        workspaceViewModel.clearLastSnapshot()
        feedbackMessage = "Cleared your last saved session"
    }

    func resetAllLocalState() {
        let didReset = workspaceViewModel.resetAllLocalState()
        feedbackMessage = didReset ? "Reset Entule on this Mac" : "Could not reset Entule data"
    }
}
