import Foundation

@MainActor
final class WorkspaceViewModel: ObservableObject {
    @Published private(set) var presets: [Preset] = []
    @Published private(set) var lastSnapshot: SessionSnapshot?

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
        guard !isSavingSnapshot else { return }
        isSavingSnapshot = true
        defer { isSavingSnapshot = false }

        appState.model.lastSnapshot = snapshot
        appState.save()
        reload()
    }

    func clearLastSnapshot() {
        guard !isBusy else { return }
        appState.model.lastSnapshot = nil
        appState.save()
        reload()
    }

    func resetAllLocalState() -> Bool {
        guard !isBusy else { return false }

        do {
            try appState.environment.store.resetState()
            reload()
            return true
        } catch {
            appState.environment.logger.error("Reset state failed: \(error.localizedDescription)")
            return false
        }
    }

    func launchPreset(_ preset: Preset) async -> LaunchReport {
        guard !isBusy else {
            return LaunchReport()
        }

        isLaunching = true
        defer { isLaunching = false }

        let report = await appState.environment.launcher.launch(
            items: preset.items,
            shortcutName: preset.shortcutName,
            dryRun: false
        )

        return report
    }

    func resumeLastSnapshot() async -> LaunchReport? {
        guard !isBusy, let snapshot = lastSnapshot else { return nil }

        isResuming = true
        defer { isResuming = false }

        let report = await appState.environment.launcher.launch(
            items: snapshot.items,
            shortcutName: snapshot.shortcutName,
            dryRun: false
        )

        return report
    }

    func detectCurrentSession() async -> DetectionResult {
        if isDetecting {
            let now = Date()
            return DetectionResult(items: [], notes: ["Detection already in progress"], warnings: [], detectorOutputs: [], startedAt: now, completedAt: now)
        }

        isDetecting = true
        defer { isDetecting = false }

        return await appState.environment.detectionCoordinator.detectAll()
    }

    var currentModel: AppStateModel {
        appState.model
    }
}
