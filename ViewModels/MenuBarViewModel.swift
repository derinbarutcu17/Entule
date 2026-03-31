import Foundation

@MainActor
final class MenuBarViewModel: ObservableObject {
    @Published private(set) var presets: [Preset] = []
    @Published private(set) var lastSnapshot: SessionSnapshot?
    @Published var infoMessage: String = "Ready"
    @Published var showPresetsWindow = false
    @Published var showSettingsWindow = false
    @Published var showSaveSheet = false
    @Published var showResumeSheet = false

    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
        reload()
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
        infoMessage = "Open Presets"
    }

    func openSettings() {
        showSettingsWindow = true
        infoMessage = "Open Settings"
    }

    func beginSaveSession() {
        showSaveSheet = true
        infoMessage = "Save Current Session"
    }

    func beginResumeSession() {
        guard canResumeLastSession else { return }
        showResumeSheet = true
        infoMessage = "Resume Last Session"
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
    }

    func deletePreset(id: UUID) {
        appState.model.presets.removeAll(where: { $0.id == id })
        appState.save()
        reload()
    }

    func saveSnapshot(_ snapshot: SessionSnapshot) {
        appState.model.lastSnapshot = snapshot
        appState.save()
        reload()
    }

    func launchPreset(_ preset: Preset) async {
        let report = await appState.environment.launcher.launch(
            items: preset.items,
            shortcutName: preset.shortcutName,
            dryRun: false
        )
        infoMessage = "Launched \(report.successes.count) items, \(report.failures.count) failed"
    }

    func resumeLastSnapshot() async -> LaunchReport? {
        guard let snapshot = lastSnapshot else { return nil }
        let report = await appState.environment.launcher.launch(
            items: snapshot.items,
            shortcutName: snapshot.shortcutName,
            dryRun: false
        )
        infoMessage = "Resumed \(report.successes.count) items"
        return report
    }

    func detectCurrentSession() async -> DetectionResult {
        await appState.environment.detectionCoordinator.detectAll()
    }
}
