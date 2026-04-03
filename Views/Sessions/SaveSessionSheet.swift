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
            ScrollView {
                VStack(alignment: .leading, spacing: AppWindowMetrics.spacingM) {
                    Text(summaryLine)
                        .font(EntuleTypography.font(13, weight: .medium))
                        .foregroundStyle(EntuleTheme.inkDim)

                    actionStrip

                    ViewThatFits(in: .horizontal) {
                        topSplit(horizontal: true)
                        topSplit(horizontal: false)
                    }

                    manualAddPanel
                    saveDetailsPanel
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
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
            Button("Save") { persistAndClose() }
        } message: {
            Text("No items are selected. Entule will save a checkpoint with only your note and shortcut.")
        }
    }

    private var actionStrip: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: AppWindowMetrics.spacingS) {
                Button("Select All") { viewModel.selectAll() }
                    .buttonStyle(EntuleSecondaryButtonStyle())
                Button("Deselect All") { viewModel.deselectAll() }
                    .buttonStyle(EntuleSecondaryButtonStyle())
                Spacer()
                if viewModel.isDetecting { ProgressView() }
            }
            VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
                HStack(spacing: AppWindowMetrics.spacingS) {
                    Button("Select All") { viewModel.selectAll() }
                        .buttonStyle(EntuleSecondaryButtonStyle())
                    Button("Deselect All") { viewModel.deselectAll() }
                        .buttonStyle(EntuleSecondaryButtonStyle())
                }
                if viewModel.isDetecting { ProgressView() }
            }
        }
        .disabled(viewModel.isDetecting || isSaving)
    }

    @ViewBuilder
    private func topSplit(horizontal: Bool) -> some View {
        if horizontal {
            HStack(alignment: .top, spacing: AppWindowMetrics.spacingM) {
                detectionPanel
                    .frame(minWidth: AppWindowMetrics.detectionColumnMinWidth, maxWidth: 280, alignment: .topLeading)
                sessionItemsPanel
            }
        } else {
            VStack(alignment: .leading, spacing: AppWindowMetrics.spacingM) {
                detectionPanel
                sessionItemsPanel
            }
        }
    }

    private var detectionPanel: some View {
        VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
            Text("Detection")
                .font(EntuleTypography.font(18, weight: .semibold))
                .foregroundStyle(EntuleTheme.ink)

            if !viewModel.detectorStatusLines.isEmpty {
                statusPanel(title: "Detector Status", rows: viewModel.detectorStatusLines, tint: EntuleTheme.inkDim)
            }

            if !viewModel.detectionWarnings.isEmpty {
                statusPanel(title: "Detection Warnings", rows: viewModel.detectionWarnings, tint: EntuleTheme.amber)
            }

            if let inputError = viewModel.inputErrorMessage {
                Text(inputError)
                    .font(EntuleTypography.font(12, weight: .medium))
                    .foregroundStyle(EntuleTheme.danger)
            }
        }
        .entulePanel()
    }

    private var sessionItemsPanel: some View {
        VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
            Text("Session Items")
                .font(EntuleTypography.font(18, weight: .semibold))
                .foregroundStyle(EntuleTheme.ink)

            if viewModel.items.isEmpty && !viewModel.isDetecting {
                VStack(alignment: .leading, spacing: AppWindowMetrics.spacingXS) {
                    Text("No Session Items Found")
                        .font(EntuleTypography.font(18, weight: .semibold))
                        .foregroundStyle(EntuleTheme.ink)
                    Text("Add URLs or use Add App, Add File, or Add Folder to build the checkpoint manually.")
                        .font(EntuleTypography.font(13))
                        .foregroundStyle(EntuleTheme.inkDim)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
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
                .frame(minHeight: AppWindowMetrics.listMinHeight)
            }
        }
        .entulePanel()
    }

    private var manualAddPanel: some View {
        VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
            Text("Manual Add")
                .font(EntuleTypography.font(18, weight: .semibold))
                .foregroundStyle(EntuleTheme.ink)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: AppWindowMetrics.spacingS) {
                    Button("Add App…") { viewModel.addManualAppsFromPicker() }
                        .buttonStyle(EntuleSecondaryButtonStyle())
                    Button("Add File…") { viewModel.addManualFilesFromPicker() }
                        .buttonStyle(EntuleSecondaryButtonStyle())
                    Button("Add Folder…") { viewModel.addManualFoldersFromPicker() }
                        .buttonStyle(EntuleSecondaryButtonStyle())
                    Spacer(minLength: 0)
                }
                VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
                    Button("Add App…") { viewModel.addManualAppsFromPicker() }
                        .buttonStyle(EntuleSecondaryButtonStyle())
                    Button("Add File…") { viewModel.addManualFilesFromPicker() }
                        .buttonStyle(EntuleSecondaryButtonStyle())
                    Button("Add Folder…") { viewModel.addManualFoldersFromPicker() }
                        .buttonStyle(EntuleSecondaryButtonStyle())
                }
            }

            ViewThatFits(in: .horizontal) {
                HStack(spacing: AppWindowMetrics.spacingS) {
                    TextField("Add URL", text: $manualURL)
                        .entuleInputField()
                    Button("Add URL") {
                        if viewModel.addManualURL(raw: manualURL) { manualURL = "" }
                    }
                    .buttonStyle(EntuleSecondaryButtonStyle())
                }
                VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
                    TextField("Add URL", text: $manualURL)
                        .entuleInputField()
                    Button("Add URL") {
                        if viewModel.addManualURL(raw: manualURL) { manualURL = "" }
                    }
                    .buttonStyle(EntuleSecondaryButtonStyle())
                }
            }
        }
        .disabled(viewModel.isDetecting || isSaving)
        .entulePanel()
    }

    private var saveDetailsPanel: some View {
        VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
            Text("Save Details")
                .font(EntuleTypography.font(18, weight: .semibold))
                .foregroundStyle(EntuleTheme.ink)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: AppWindowMetrics.spacingS) {
                    TextField("Note", text: $viewModel.note)
                        .entuleInputField()
                    TextField("Shortcut Name (optional)", text: $viewModel.shortcutName)
                        .entuleInputField()
                }
                VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
                    TextField("Note", text: $viewModel.note)
                        .entuleInputField()
                    TextField("Shortcut Name (optional)", text: $viewModel.shortcutName)
                        .entuleInputField()
                }
            }
        }
        .entulePanel()
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
        guard let idx = viewModel.items.firstIndex(where: { $0.id == id }) else { return nil }
        return $viewModel.items[idx]
    }

    private func statusPanel(title: String, rows: [String], tint: Color) -> some View {
        VStack(alignment: .leading, spacing: AppWindowMetrics.spacingXS) {
            Text(title)
                .font(EntuleTypography.font(16, weight: .semibold))
                .foregroundStyle(EntuleTheme.ink)
            ForEach(rows, id: \.self) { row in
                Text("• \(row)")
                    .font(EntuleTypography.font(12))
                    .foregroundStyle(tint)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .entulePanel()
    }

    private func closeView() {
        onClose?()
    }
}
