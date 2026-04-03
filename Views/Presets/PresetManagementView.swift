import SwiftUI

struct PresetManagementView: View {
    @ObservedObject var workspaceViewModel: WorkspaceViewModel

    @State private var editingPreset: Preset?
    @State private var isCreating = false

    var body: some View {
        AppPaneContainer {
            if workspaceViewModel.presets.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("No presets yet")
                        .font(.headline)
                        .foregroundStyle(EntuleTheme.moon)
                    Text("Create a preset to launch the same apps, folders, files, and URLs in one click.")
                        .font(.system(size: 13))
                        .foregroundStyle(EntuleTheme.moonDim)

                    Button("New Preset") { isCreating = true }
                        .buttonStyle(EntulePrimaryButtonStyle())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .entulePanel()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(workspaceViewModel.presets) { preset in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(preset.name)
                                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                                            .foregroundStyle(EntuleTheme.ink)
                                        Text("\(preset.items.count) items")
                                            .font(.system(size: 13))
                                            .foregroundStyle(EntuleTheme.inkDim)
                                    }
                                    Spacer()
                                }

                                HStack(spacing: 10) {
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
                            .entulePanel()
                        }
                    }
                }
                .frame(height: AppWindowMetrics.presetsListHeight)
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
}
