import AppKit
import Foundation

@MainActor
final class PresetEditorViewModel: ObservableObject {
    @Published var name: String
    @Published var shortcutName: String
    @Published var items: [SessionItem]

    let existingPresetID: UUID?
    private let createdAt: Date

    init(preset: Preset? = nil) {
        existingPresetID = preset?.id
        createdAt = preset?.createdAt ?? Date()
        name = preset?.name ?? ""
        shortcutName = preset?.shortcutName ?? ""
        items = preset?.items ?? []
    }

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func addAppItems() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.application]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true

        if panel.runModal() == .OK {
            for url in panel.urls {
                let path = url.path
                items.append(
                    SessionItem(
                        kind: .app,
                        displayName: BundleAppResolver.displayName(forAppPath: path),
                        value: BundleAppResolver.bundleIdentifier(forAppPath: path) ?? path,
                        appPath: path,
                        source: "manual",
                        isSelected: true
                    )
                )
            }
        }
    }

    func addFileItems() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true

        if panel.runModal() == .OK {
            for url in panel.urls {
                let isDir = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                items.append(
                    SessionItem(
                        kind: isDir ? .folder : .file,
                        displayName: url.lastPathComponent,
                        value: url.path,
                        source: "manual",
                        isSelected: true
                    )
                )
            }
        }
    }

    func addURLItem(raw: String) {
        guard let normalized = URLNormalizer.normalize(raw) else { return }
        items.append(
            SessionItem(
                kind: .url,
                displayName: normalized,
                value: normalized,
                source: "manual",
                isSelected: true
            )
        )
    }

    func removeItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }

    func moveItems(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }

    func toPreset() -> Preset {
        Preset(
            id: existingPresetID ?? UUID(),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            items: items,
            shortcutName: shortcutName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : shortcutName,
            createdAt: createdAt,
            updatedAt: Date()
        )
    }
}
