import Foundation

@MainActor
final class SaveSessionViewModel: ObservableObject {
    @Published var note: String = ""
    @Published var shortcutName: String = ""
    @Published var items: [SessionItem] = []
    @Published var isDetecting = false
    @Published var detectionErrors: [String] = []

    func loadDetectionResult(_ result: DetectionResult) {
        items = result.items
        detectionErrors = result.errors
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

    func removeItem(_ item: SessionItem) {
        items.removeAll(where: { $0.id == item.id })
    }

    func addManualURL(raw: String) {
        guard let normalized = URLNormalizer.normalize(raw) else { return }
        items.append(SessionItem(kind: .url, displayName: normalized, value: normalized, source: "manual", isSelected: true))
    }

    func addManualPath(path: String, isFolder: Bool) {
        let url = URL(fileURLWithPath: path)
        items.append(SessionItem(kind: isFolder ? .folder : .file, displayName: url.lastPathComponent, value: path, source: "manual", isSelected: true))
    }

    func addManualApp(name: String, bundleIDOrPath: String, appPath: String?) {
        items.append(SessionItem(kind: .app, displayName: name, value: bundleIDOrPath, appPath: appPath, source: "manual", isSelected: true))
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
