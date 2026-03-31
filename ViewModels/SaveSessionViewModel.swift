import AppKit
import Foundation

@MainActor
final class SaveSessionViewModel: ObservableObject {
    @Published var note: String = ""
    @Published var shortcutName: String = ""
    @Published var items: [SessionItem] = []
    @Published var isDetecting = false
    @Published var detectionNotes: [String] = []
    @Published var detectionWarnings: [String] = []
    @Published var detectorStatusLines: [String] = []
    @Published var inputErrorMessage: String?

    func loadDetectionResult(_ result: DetectionResult) {
        items = result.items
        detectionNotes = result.notes
        detectionWarnings = result.warnings
        detectorStatusLines = result.detectorOutputs.map(detectorStatusLine(for:))
    }

    var selectedCount: Int {
        items.filter(\.isSelected).count
    }

    var detectedCount: Int {
        items.count
    }

    var detectedSourceCount: Int {
        Set(items.map(\.source)).count
    }

    func shouldConfirmEmptySelection() -> Bool {
        selectedCount == 0
    }

    func selectAll() {
        items = items.map { item in
            var copy = item
            copy.isSelected = true
            return copy
        }
    }

    func deselectAll() {
        items = items.map { item in
            var copy = item
            copy.isSelected = false
            return copy
        }
    }

    func clearInputError() {
        inputErrorMessage = nil
    }

    func removeItem(_ item: SessionItem) {
        items.removeAll(where: { $0.id == item.id })
    }

    @discardableResult
    func addManualURL(raw: String) -> Bool {
        guard let normalized = URLNormalizer.normalize(raw) else {
            inputErrorMessage = "Invalid URL. Use a valid http/https URL."
            return false
        }
        items.append(SessionItem(kind: .url, displayName: normalized, value: normalized, source: "manual", isSelected: true))
        inputErrorMessage = nil
        return true
    }

    @discardableResult
    func addManualPath(path: String, isFolder: Bool) -> Bool {
        let trimmed = path.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            inputErrorMessage = "Path is empty."
            return false
        }

        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: trimmed, isDirectory: &isDirectory) else {
            inputErrorMessage = "Path does not exist: \(trimmed)"
            return false
        }

        if isFolder && !isDirectory.boolValue {
            inputErrorMessage = "Selected path is not a folder."
            return false
        }

        if !isFolder && isDirectory.boolValue {
            inputErrorMessage = "Selected path is a folder. Use Add Folder."
            return false
        }

        let url = URL(fileURLWithPath: trimmed)
        items.append(SessionItem(kind: isFolder ? .folder : .file, displayName: url.lastPathComponent, value: trimmed, source: "manual", isSelected: true))
        inputErrorMessage = nil
        return true
    }

    @discardableResult
    func addManualApp(name: String, bundleIDOrPath: String, appPath: String?) -> Bool {
        if let appPath, !appPath.isEmpty, !FileManager.default.fileExists(atPath: appPath) {
            inputErrorMessage = "App path does not exist: \(appPath)"
            return false
        }

        items.append(SessionItem(kind: .app, displayName: name, value: bundleIDOrPath, appPath: appPath, source: "manual", isSelected: true))
        inputErrorMessage = nil
        return true
    }

    func addManualAppsFromPicker() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.application]
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true

        guard panel.runModal() == .OK else { return }

        for url in panel.urls {
            _ = addManualApp(
                name: BundleAppResolver.displayName(forAppPath: url.path),
                bundleIDOrPath: BundleAppResolver.bundleIdentifier(forAppPath: url.path) ?? url.path,
                appPath: url.path
            )
        }
    }

    func addManualFilesFromPicker() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true

        guard panel.runModal() == .OK else { return }
        panel.urls.forEach { _ = addManualPath(path: $0.path, isFolder: false) }
    }

    func addManualFoldersFromPicker() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true

        guard panel.runModal() == .OK else { return }
        panel.urls.forEach { _ = addManualPath(path: $0.path, isFolder: true) }
    }

    func toSnapshot() -> SessionSnapshot {
        SessionSnapshot(
            note: note,
            items: items.filter(\.isSelected),
            shortcutName: shortcutName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : shortcutName,
            createdAt: Date()
        )
    }

    private func detectorStatusLine(for output: DetectorOutput) -> String {
        let title = output.detectorName.replacingOccurrences(of: "Detector", with: "")
        switch output.status {
        case .success:
            return output.items.isEmpty ? "\(title): no items" : "\(title): \(output.items.count) items"
        case .notRunning:
            return "\(title): not running"
        case .unavailable:
            return output.notes.first ?? "\(title): unavailable"
        case .warning:
            return "\(title): \(output.warnings.count) warning(s)"
        case .failed:
            return "\(title): failed"
        }
    }
}
