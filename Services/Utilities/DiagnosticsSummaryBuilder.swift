import Foundation

struct DiagnosticsSummaryBuilder {
    static func build(
        model: AppStateModel,
        stateFilePath: String,
        legacyStateExists: Bool,
        supportedDetectors: [String],
        bundle: Bundle = .main
    ) -> String {
        let version = (bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "unknown"
        let build = (bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String) ?? "unknown"

        let lastSnapshotExists = model.lastSnapshot != nil
        let lastSnapshotItemCount = model.lastSnapshot?.items.count ?? 0

        return [
            "Entule Diagnostics",
            "Version: \(version) (\(build))",
            "Preset count: \(model.presets.count)",
            "Last snapshot exists: \(lastSnapshotExists ? "yes" : "no")",
            "Last snapshot item count: \(lastSnapshotItemCount)",
            "State file: \(stateFilePath)",
            "Legacy WorkCheckpoint state exists: \(legacyStateExists ? "yes" : "no")",
            "Supported detectors: \(supportedDetectors.joined(separator: ", "))"
        ].joined(separator: "\n")
    }
}
