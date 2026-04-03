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
                List {
                    ForEach(workspaceViewModel.presets) { preset in
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(preset.name)
                                    .foregroundStyle(EntuleTheme.moon)
                                Text("\(preset.items.count) items")
                                    .font(.caption)
                                    .foregroundStyle(EntuleTheme.moonDim)
                            }
                            Spacer()
                            Button("Launch") {
                                Task { await workspaceViewModel.launchPreset(preset) }
                            }
                            .buttonStyle(EntuleSecondaryButtonStyle())
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
                        .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .frame(height: AppWindowMetrics.presetsListHeight)
                .entulePanel()
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
