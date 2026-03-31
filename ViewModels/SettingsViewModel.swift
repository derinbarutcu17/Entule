import AppKit
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var showPermissionsHint: Bool = true
    @Published var diagnosticsText: String = ""
    @Published var feedbackMessage: String = ""

    private let menuBarViewModel: MenuBarViewModel

    init(menuBarViewModel: MenuBarViewModel) {
        self.menuBarViewModel = menuBarViewModel
        refreshDiagnostics()
    }

    var permissionsHint: String {
        PermissionsHelper.appleEventsHelpText()
    }

    func refreshDiagnostics() {
        menuBarViewModel.reload()

        do {
            let stateURL = try FilePaths.stateFileURL()
            let legacyURL = try FilePaths.legacyStateFileURL()

            diagnosticsText = DiagnosticsSummaryBuilder.build(
                model: menuBarViewModel.currentModel,
                stateFilePath: stateURL.path,
                legacyStateExists: FileManager.default.fileExists(atPath: legacyURL.path),
                supportedDetectors: DetectionCoordinator.supportedDetectorNames
            )
        } catch {
            diagnosticsText = "Diagnostics unavailable: \(error.localizedDescription)"
        }
    }

    func revealDataFolder() {
        do {
            let directory = try FilePaths.applicationSupportDirectory()
            NSWorkspace.shared.open(directory)
            feedbackMessage = "Opened Entule data folder"
        } catch {
            feedbackMessage = "Could not open data folder"
        }
    }

    func revealStateFile() {
        do {
            let stateURL = try FilePaths.stateFileURL()
            if FileManager.default.fileExists(atPath: stateURL.path) {
                NSWorkspace.shared.activateFileViewerSelecting([stateURL])
                feedbackMessage = "Revealed state.json"
            } else {
                feedbackMessage = "state.json does not exist yet"
            }
        } catch {
            feedbackMessage = "Could not resolve state.json path"
        }
    }

    func clearLastSnapshot() {
        menuBarViewModel.clearLastSnapshot()
        refreshDiagnostics()
        feedbackMessage = "Cleared last snapshot"
    }

    func resetAllLocalState() {
        let didReset = menuBarViewModel.resetAllLocalState()
        refreshDiagnostics()
        feedbackMessage = didReset ? "Reset local Entule data" : "Could not reset local data"
    }

    func copyDiagnostics() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(diagnosticsText, forType: .string)
        feedbackMessage = "Copied diagnostics"
    }
}
