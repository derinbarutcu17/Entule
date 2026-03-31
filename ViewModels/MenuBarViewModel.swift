import Foundation

@MainActor
final class MenuBarViewModel: ObservableObject {
    @Published private(set) var presets: [Preset] = []
    @Published private(set) var lastSnapshot: SessionSnapshot?
    @Published var statusLine: String = "Ready"
    @Published var showPresetsWindow = false
    @Published var showSettingsWindow = false
    @Published var showSaveSheet = false
    @Published var showResumeSheet = false

    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    func reload() {
        appState.load()
        presets = appState.model.presets.sorted { $0.updatedAt > $1.updatedAt }
        lastSnapshot = appState.model.lastSnapshot
    }

    var canResumeLastSession: Bool {
        lastSnapshot != nil
    }

    func openPresets() {
        showPresetsWindow = true
        statusLine = "Presets"
    }

    func openSettings() {
        showSettingsWindow = true
        statusLine = "Settings"
    }

    func beginSaveSession() {
        showSaveSheet = true
        statusLine = "Save session"
    }

    func beginResumeSession() {
        guard canResumeLastSession else { return }
        showResumeSheet = true
        statusLine = "Resume session"
    }

    func savePreset(_ preset: Preset) {
        var updated = appState.model
        if let idx = updated.presets.firstIndex(where: { $0.id == preset.id }) {
            updated.presets[idx] = preset
        } else {
            updated.presets.append(preset)
        }
        appState.model = updated
        appState.save()
        reload()
        statusLine = "Preset saved"
    }

    func deletePreset(id: UUID) {
        appState.model.presets.removeAll(where: { $0.id == id })
        appState.save()
        reload()
        statusLine = "Preset deleted"
    }

    func saveSnapshot(_ snapshot: SessionSnapshot) {
        appState.model.lastSnapshot = snapshot
        appState.save()
        reload()
        statusLine = "Saved \(snapshot.items.count) items"
    }

    func launchPreset(_ preset: Preset) async -> LaunchReport {
        let report = await appState.environment.launcher.launch(
            items: preset.items,
            shortcutName: preset.shortcutName,
            dryRun: false
        )

        statusLine = "Preset \(preset.name): \(report.succeededCount) ok, \(report.failedCount) failed"
        return report
    }

    func resumeLastSnapshot() async -> LaunchReport? {
        guard let snapshot = lastSnapshot else { return nil }
        let report = await appState.environment.launcher.launch(
            items: snapshot.items,
            shortcutName: snapshot.shortcutName,
            dryRun: false
        )

        statusLine = "Resume: \(report.succeededCount) ok, \(report.failedCount) failed"
        return report
    }

    func detectCurrentSession() async -> DetectionResult {
        await appState.environment.detectionCoordinator.detectAll()
    }
}
