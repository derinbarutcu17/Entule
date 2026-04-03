import SwiftUI

struct PresetManagementView: View {
    @ObservedObject var workspaceViewModel: WorkspaceViewModel

    @State private var editingPreset: Preset?
    @State private var isCreating = false

    var body: some View {
        AppPaneContainer {
            if workspaceViewModel.presets.isEmpty {
                VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
                    Text("No presets yet")
                        .font(EntuleTypography.font(22, weight: .semibold))
                        .foregroundStyle(EntuleTheme.ink)
                    Text("Create a preset to launch the same apps, folders, files, and URLs in one click.")
                        .font(EntuleTypography.font(14))
                        .foregroundStyle(EntuleTheme.inkDim)

                    Button("New Preset") { isCreating = true }
                        .buttonStyle(EntulePrimaryButtonStyle())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .entulePanel()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppWindowMetrics.spacingM) {
                        ForEach(workspaceViewModel.presets) { preset in
                            VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(preset.name)
                                            .font(EntuleTypography.font(20, weight: .semibold))
                                            .foregroundStyle(EntuleTheme.ink)
                                            .fixedSize(horizontal: false, vertical: true)
                                        Text("\(preset.items.count) items")
                                            .font(EntuleTypography.font(13))
                                            .foregroundStyle(EntuleTheme.inkDim)
                                    }
                                    Spacer()
                                }

                                actionRow(for: preset)
                            }
                            .entulePanel()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        } toolbar: {
            Spacer()
            Button("New Preset") { isCreating = true }
                .buttonStyle(EntulePrimaryButtonStyle())
        }
        .sheet(item: $editingPreset) { preset in
            PresetEditorView(viewModel: PresetEditorViewModel(preset: preset)) { updated in
                workspaceViewModel.savePreset(updated)
            }
        }
        .sheet(isPresented: $isCreating) {
            PresetEditorView(viewModel: PresetEditorViewModel()) { preset in
                workspaceViewModel.savePreset(preset)
            }
        }
    }

    @ViewBuilder
    private func actionRow(for preset: Preset) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: AppWindowMetrics.spacingS) {
                actionButtons(for: preset)
                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
                actionButtons(for: preset)
            }
        }
    }

    private func actionButtons(for preset: Preset) -> some View {
        Group {
            Button("Launch") {
                Task { await workspaceViewModel.launchPreset(preset) }
            }
            .buttonStyle(EntulePrimaryButtonStyle())
            .disabled(workspaceViewModel.isBusy)

            Button("Edit") {
                editingPreset = preset
            }
            .buttonStyle(EntuleSecondaryButtonStyle())

            Button("Delete", role: .destructive) {
                workspaceViewModel.deletePreset(id: preset.id)
            }
            .buttonStyle(EntuleSecondaryButtonStyle())
        }
    }
}
