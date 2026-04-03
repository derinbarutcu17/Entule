import SwiftUI

struct SaveSessionSheet: View {
    @StateObject var viewModel: SaveSessionViewModel
    @ObservedObject var workspaceViewModel: WorkspaceViewModel
    var onClose: (() -> Void)? = nil

    @State private var manualURL = ""
    @State private var confirmSaveWithZeroItems = false
    @State private var isSaving = false

    private var groupedItems: [SessionItemKind: [SessionItem]] {
        Dictionary(grouping: viewModel.items, by: { $0.kind })
    }

    var body: some View {
        AppPaneContainer {
            VStack(alignment: .leading, spacing: AppWindowMetrics.sectionSpacing) {
                Text(summaryLine)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(EntuleTheme.inkDim)

                HStack(spacing: 10) {
                    Button("Select All") { viewModel.selectAll() }
                        .buttonStyle(EntuleSecondaryButtonStyle())
                    Button("Deselect All") { viewModel.deselectAll() }
                        .buttonStyle(EntuleSecondaryButtonStyle())
                    Spacer()
                    if viewModel.isDetecting { ProgressView() }
                }
                .disabled(viewModel.isDetecting || isSaving)

                HStack(alignment: .top, spacing: AppWindowMetrics.sectionSpacing) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Detection")
                            .font(.headline)
                            .foregroundStyle(EntuleTheme.moon)

                        if !viewModel.detectorStatusLines.isEmpty {
                            statusPanel(title: "Detector Status", rows: viewModel.detectorStatusLines, tint: EntuleTheme.moonDim)
                        }

                        if !viewModel.detectionWarnings.isEmpty {
                            statusPanel(title: "Detection Warnings", rows: viewModel.detectionWarnings, tint: EntuleTheme.amber)
                        }

                        if let inputError = viewModel.inputErrorMessage {
                            Text(inputError)
                                .font(.caption)
                                .foregroundStyle(EntuleTheme.danger)
                        }
                    }
                    .frame(width: AppWindowMetrics.saveDetectionColumnWidth)
                    .frame(
                        minHeight: AppWindowMetrics.saveContentHeight,
                        maxHeight: AppWindowMetrics.saveContentHeight,
                        alignment: .topLeading
                    )

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Session Items")
                            .font(.headline)
                            .foregroundStyle(EntuleTheme.moon)

                        if viewModel.items.isEmpty && !viewModel.isDetecting {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("No Session Items Found")
                                    .font(.headline)
                                    .foregroundStyle(EntuleTheme.moon)
                                Text("Add URLs or use Add App, Add File, or Add Folder to build the checkpoint manually.")
                                    .font(.caption)
                                    .foregroundStyle(EntuleTheme.moonDim)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .entulePanel()
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
                                                    .listRowBackground(Color.clear)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .listStyle(.plain)
                            .frame(height: AppWindowMetrics.saveContentHeight)
                            .entulePanel()
                        }
                    }
                    .frame(
                        maxWidth: .infinity,
                        minHeight: AppWindowMetrics.saveContentHeight,
                        maxHeight: AppWindowMetrics.saveContentHeight,
                        alignment: .topLeading
                    )
                }
                .frame(height: AppWindowMetrics.saveContentHeight, alignment: .top)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Manual Add")
                        .font(.headline)
                        .foregroundStyle(EntuleTheme.moon)

                    HStack {
                        Button("Add App…") { viewModel.addManualAppsFromPicker() }
                            .buttonStyle(EntuleSecondaryButtonStyle())
                        Button("Add File…") { viewModel.addManualFilesFromPicker() }
                            .buttonStyle(EntuleSecondaryButtonStyle())
                        Button("Add Folder…") { viewModel.addManualFoldersFromPicker() }
                            .buttonStyle(EntuleSecondaryButtonStyle())
                        Spacer()
                    }

                    HStack {
                        TextField("Add URL", text: $manualURL)
                            .entuleInputField()
                        Button("Add URL") {
                            if viewModel.addManualURL(raw: manualURL) {
                                manualURL = ""
                            }
                        }
                        .buttonStyle(EntuleSecondaryButtonStyle())
                    }
                }
                .disabled(viewModel.isDetecting || isSaving)
                .entulePanel()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Save Details")
                        .font(.headline)
                        .foregroundStyle(EntuleTheme.moon)

                    HStack(spacing: 12) {
                        TextField("Note", text: $viewModel.note)
                            .entuleInputField()
                        TextField("Shortcut Name (optional)", text: $viewModel.shortcutName)
                            .entuleInputField()
                    }
                }
                .entulePanel()

            }
        } toolbar: {
            Button("Close") { closeView() }
                .buttonStyle(EntuleSecondaryButtonStyle())
                .disabled(isSaving)
            Spacer()
            Button(viewModel.isDetecting ? "Detecting…" : (isSaving ? "Saving…" : "Save Checkpoint")) {
                saveSnapshotWithChecks()
            }
            .buttonStyle(EntulePrimaryButtonStyle())
            .disabled(viewModel.isDetecting || isSaving)
        }
        .task {
            viewModel.isDetecting = true
            let result = await workspaceViewModel.detectCurrentSession()
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
        "Detected \(viewModel.detectedCount) items from \(viewModel.detectedSourceCount) sources • Selected \(viewModel.selectedCount)"
    }

    private func saveSnapshotWithChecks() {
        if viewModel.shouldConfirmEmptySelection() {
            confirmSaveWithZeroItems = true
        } else {
            persistAndClose()
        }
    }

    private func persistAndClose() {
        guard !isSaving else { return }
        isSaving = true
        workspaceViewModel.saveSnapshot(viewModel.toSnapshot())
        closeView()
    }

    private func binding(for id: UUID) -> Binding<SessionItem>? {
        guard let idx = viewModel.items.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        return $viewModel.items[idx]
    }

    private func statusPanel(title: String, rows: [String], tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(EntuleTheme.moon)
            ForEach(rows, id: \.self) { row in
                Text("• \(row)")
                    .font(.caption)
                    .foregroundStyle(tint)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .entulePanel()
    }

    private func closeView() {
        onClose?()
    }
}
