import SwiftUI

struct SaveSessionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: SaveSessionViewModel
    @ObservedObject var menuBarViewModel: MenuBarViewModel

    @State private var manualURL = ""
    @State private var manualPath = ""
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
                Text("Selected: \(viewModel.selectedCount)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if viewModel.isDetecting { ProgressView() }
            }

            if !viewModel.detectionWarnings.isEmpty {
                GroupBox("Detection Warnings") {
                    VStack(alignment: .leading) {
                        ForEach(viewModel.detectionWarnings, id: \.self) { warning in
                            Text("• \(warning)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            if let inputError = viewModel.inputErrorMessage {
                Text(inputError)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

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

            GroupBox("Manual Add") {
                HStack {
                    TextField("URL", text: $manualURL)
                    Button("Add URL") {
                        if viewModel.addManualURL(raw: manualURL) {
                            manualURL = ""
                        }
                    }
                }

                HStack {
                    TextField("Path", text: $manualPath)
                    Button("Add File") {
                        if viewModel.addManualPath(path: manualPath, isFolder: false) {
                            manualPath = ""
                        }
                    }
                    Button("Add Folder") {
                        if viewModel.addManualPath(path: manualPath, isFolder: true) {
                            manualPath = ""
                        }
                    }
                }
            }

            TextField("Note", text: $viewModel.note)
            TextField("Shortcut Name (optional)", text: $viewModel.shortcutName)

            HStack {
                Button("Cancel") { dismiss() }
                Spacer()
                Button("Save Snapshot") {
                    saveSnapshotWithChecks()
                }
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
        .onChange(of: manualPath) { _ in viewModel.clearInputError() }
        .alert("Save snapshot with zero selected items?", isPresented: $confirmSaveWithZeroItems) {
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                persistAndClose()
            }
        } message: {
            Text("This will replace the last snapshot with an empty item list.")
        }
    }

    private func saveSnapshotWithChecks() {
        if viewModel.selectedCount == 0 {
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
