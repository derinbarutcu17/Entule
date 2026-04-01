import Foundation

@MainActor
final class MenuBarViewModel: ObservableObject {
    @Published private(set) var presets: [Preset] = []
    @Published private(set) var lastSnapshot: SessionSnapshot?
    @Published var statusLine: String = "Ready"

    @Published private(set) var isDetecting = false
    @Published private(set) var isLaunching = false
    @Published private(set) var isResuming = false
    @Published private(set) var isSavingSnapshot = false

    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    var isBusy: Bool {
        isDetecting || isLaunching || isResuming || isSavingSnapshot
    }

    func reload() {
        appState.load()
        presets = appState.model.presets.sorted { $0.updatedAt > $1.updatedAt }
        lastSnapshot = appState.model.lastSnapshot
    }

    var canResumeLastSession: Bool {
        !isBusy && lastSnapshot != nil
    }

    func openPresets() {
        statusLine = "Presets"
    }

    func openSettings() {
        statusLine = "Settings"
    }

    func beginSaveSession() {
        guard !isBusy else { return }
        statusLine = "Save session"
    }

    func beginResumeSession() {
        guard canResumeLastSession else { return }
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
        guard !isSavingSnapshot else { return }
        isSavingSnapshot = true
        defer { isSavingSnapshot = false }

        appState.model.lastSnapshot = snapshot
        appState.save()
        reload()
        statusLine = "Saved \(snapshot.items.count) items"
    }

    func clearLastSnapshot() {
        guard !isBusy else { return }
        appState.model.lastSnapshot = nil
        appState.save()
        reload()
        statusLine = "Last snapshot cleared"
    }

    func resetAllLocalState() -> Bool {
        guard !isBusy else { return false }

        do {
            try appState.environment.store.resetState()
            reload()
            statusLine = "Local data reset"
            return true
        } catch {
            appState.environment.logger.error("Reset state failed: \(error.localizedDescription)")
            statusLine = "Reset failed"
            return false
        }
    }

    func launchPreset(_ preset: Preset) async -> LaunchReport {
        guard !isBusy else {
            return LaunchReport()
        }

        isLaunching = true
        statusLine = "Launching preset…"
        defer { isLaunching = false }

        let report = await appState.environment.launcher.launch(
            items: preset.items,
            shortcutName: preset.shortcutName,
            dryRun: false
        )

        statusLine = "Preset \(preset.name): \(report.succeededCount) ok, \(report.failedCount) failed"
        return report
    }

    func resumeLastSnapshot() async -> LaunchReport? {
        guard !isBusy, let snapshot = lastSnapshot else { return nil }

        isResuming = true
        statusLine = "Resuming snapshot…"
        defer { isResuming = false }

        let report = await appState.environment.launcher.launch(
            items: snapshot.items,
            shortcutName: snapshot.shortcutName,
            dryRun: false
        )

        statusLine = "Resume: \(report.succeededCount) ok, \(report.failedCount) failed"
        return report
    }

    func detectCurrentSession() async -> DetectionResult {
        if isDetecting {
            let now = Date()
            return DetectionResult(items: [], notes: ["Detection already in progress"], warnings: [], detectorOutputs: [], startedAt: now, completedAt: now)
        }

        isDetecting = true
        statusLine = "Detecting session…"
        defer { isDetecting = false }

        return await appState.environment.detectionCoordinator.detectAll()
    }

    var currentModel: AppStateModel {
        appState.model
    }
}
