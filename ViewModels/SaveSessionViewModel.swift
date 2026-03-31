import Foundation

@MainActor
final class SaveSessionViewModel: ObservableObject {
    @Published var note: String = ""
    @Published var shortcutName: String = ""
    @Published var items: [SessionItem] = []
    @Published var isDetecting = false
    @Published var detectionWarnings: [String] = []
    @Published var inputErrorMessage: String?

    func loadDetectionResult(_ result: DetectionResult) {
        items = result.items
        detectionWarnings = result.warnings
    }

    var selectedCount: Int {
        items.filter(\.isSelected).count
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

    func toSnapshot() -> SessionSnapshot {
        SessionSnapshot(
            note: note,
            items: items.filter(\.isSelected),
            shortcutName: shortcutName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : shortcutName,
            createdAt: Date()
        )
    }
}
