import SwiftUI

struct PresetManagementView: View {
    @ObservedObject var workspaceViewModel: WorkspaceViewModel

    @State private var editingPreset: Preset?
    @State private var isCreating = false
    @State private var pendingDeletePreset: Preset?

    var body: some View {
        AppPaneContainer {
            presetsPanel
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
        .alert("Delete preset?", isPresented: deleteAlertBinding) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let pendingDeletePreset {
                    workspaceViewModel.deletePreset(id: pendingDeletePreset.id)
                }
                pendingDeletePreset = nil
            }
        } message: {
            if let pendingDeletePreset {
                Text("This will permanently delete \"\(pendingDeletePreset.name)\".")
            } else {
                Text("This action cannot be undone.")
            }
        }
    }

    private var presetsPanel: some View {
        VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
            if workspaceViewModel.presets.isEmpty {
                emptyStateContent
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else {
                headerRow
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .entulePanel()
    }

    private var emptyStateContent: some View {
        HStack(alignment: .top, spacing: AppWindowMetrics.spacingM) {
            VStack(alignment: .leading, spacing: 6) {
                Text("No presets yet")
                    .font(EntuleTypography.font(22, weight: .semibold))
                    .foregroundStyle(EntuleTheme.ink)
                    .multilineTextAlignment(.leading)

                Text("Create a preset to launch the same apps, folders, files, and URLs in one click.")
                    .font(EntuleTypography.font(14))
                    .foregroundStyle(EntuleTheme.inkDim)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: 420, alignment: .leading)
            }
            Spacer(minLength: 0)
            newPresetOrb
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private var headerRow: some View {
        HStack(alignment: .center, spacing: AppWindowMetrics.spacingM) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Reusable launch bundles for apps, links, files, and folders.")
                    .font(EntuleTypography.font(13))
                    .foregroundStyle(EntuleTheme.inkDim)
            }
            Spacer(minLength: 0)
            newPresetOrb
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
                pendingDeletePreset = preset
            }
            .buttonStyle(EntuleSecondaryButtonStyle())
        }
    }

    private var newPresetOrb: some View {
        Button {
            isCreating = true
        } label: {
            Circle()
                .fill(EntuleTheme.primaryButtonGradient)
                .frame(width: 112, height: 112)
                .overlay {
                    VStack(spacing: 6) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 22, weight: .semibold))
                        Text("New Preset")
                            .font(EntuleTypography.font(15, weight: .bold))
                    }
                    .foregroundStyle(Color.white)
                }
                .shadow(color: EntuleTheme.orange.opacity(0.18), radius: 16, y: 10)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Create New Preset")
    }

    private var deleteAlertBinding: Binding<Bool> {
        Binding(
            get: { pendingDeletePreset != nil },
            set: { isPresented in
                if !isPresented {
                    pendingDeletePreset = nil
                }
            }
        )
    }
}
