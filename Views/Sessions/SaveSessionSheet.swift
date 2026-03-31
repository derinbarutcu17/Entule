import SwiftUI

struct SaveSessionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: SaveSessionViewModel
    @ObservedObject var menuBarViewModel: MenuBarViewModel

    @State private var manualURL = ""
    @State private var confirmSaveWithZeroItems = false

    private var groupedItems: [SessionItemKind: [SessionItem]] {
        Dictionary(grouping: viewModel.items, by: { $0.kind })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Save Current Session")
                .font(.title3.bold())

            HStack {
                Button("Select All") { viewModel.selectAll() }
                Button("Deselect All") { viewModel.deselectAll() }
                Spacer()
                if viewModel.isDetecting { ProgressView() }
            }

            Text(summaryLine)
                .font(.caption)
                .foregroundStyle(.secondary)

            if !viewModel.detectorStatusLines.isEmpty {
                GroupBox("Detector Status") {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(viewModel.detectorStatusLines, id: \.self) { line in
                            Text("• \(line)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            if !viewModel.detectionWarnings.isEmpty {
                GroupBox("Detection Warnings") {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(viewModel.detectionWarnings, id: \.self) { warning in
                            Text("• \(warning)")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }

            if let inputError = viewModel.inputErrorMessage {
                Text(inputError)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            if viewModel.items.isEmpty && !viewModel.isDetecting {
                VStack(alignment: .leading, spacing: 6) {
                    Text("No Session Items Found")
                        .font(.headline)
                    Text("Add URLs or use Add App/File/Folder to include items manually.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 12)
            } else {
                List {
                    ForEach(SessionItemKind.allCases, id: \.self) { kind in
                        if let indexList = groupedItems[kind], !indexList.isEmpty {
                            Section(kind.rawValue.uppercased()) {
                                ForEach(indexList) { sectionItem in
                                    if let binding = binding(for: sectionItem.id) {
                                        SessionItemRow(item: binding) {
                                            viewModel.removeItem(sectionItem)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            GroupBox("Manual Add") {
                HStack {
                    Button("Add App…") { viewModel.addManualAppsFromPicker() }
                    Button("Add File…") { viewModel.addManualFilesFromPicker() }
                    Button("Add Folder…") { viewModel.addManualFoldersFromPicker() }
                    Spacer()
                }

                HStack {
                    TextField("Add URL", text: $manualURL)
                    Button("Add URL") {
                        if viewModel.addManualURL(raw: manualURL) {
                            manualURL = ""
                        }
                    }
                }
            }

            TextField("Note", text: $viewModel.note)
            TextField("Shortcut Name (optional)", text: $viewModel.shortcutName)

            HStack {
                Button("Cancel") { dismiss() }
                Spacer()
                Button(viewModel.isDetecting ? "Detecting…" : "Save Snapshot") {
                    saveSnapshotWithChecks()
                }
                .disabled(viewModel.isDetecting)
            }
        }
        .padding()
        .task {
            viewModel.isDetecting = true
            let result = await menuBarViewModel.detectCurrentSession()
            viewModel.loadDetectionResult(result)
            viewModel.isDetecting = false
        }
        .onChange(of: manualURL) { _ in viewModel.clearInputError() }
        .alert("Save empty snapshot?", isPresented: $confirmSaveWithZeroItems) {
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                persistAndClose()
            }
        } message: {
            Text("No items are selected. Entule will save a checkpoint with only your note and shortcut.")
        }
    }

    private var summaryLine: String {
        "Detected \(viewModel.detectedCount) items from \(viewModel.detectedSourceCount) sources. Selected \(viewModel.selectedCount)."
    }

    private func saveSnapshotWithChecks() {
        if viewModel.shouldConfirmEmptySelection() {
            confirmSaveWithZeroItems = true
        } else {
            persistAndClose()
        }
    }

    private func persistAndClose() {
        menuBarViewModel.saveSnapshot(viewModel.toSnapshot())
        dismiss()
    }

    private func binding(for id: UUID) -> Binding<SessionItem>? {
        guard let idx = viewModel.items.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        return $viewModel.items[idx]
    }
}
