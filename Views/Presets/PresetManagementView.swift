import SwiftUI

struct PresetManagementView: View {
    @ObservedObject var menuBarViewModel: MenuBarViewModel

    @State private var editingPreset: Preset?
    @State private var isCreating = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Presets")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(EntuleTheme.moon)
                    Text("Reusable launch sets for repeatable work sessions.")
                        .font(.caption)
                        .foregroundStyle(EntuleTheme.moonDim)
                }
                Spacer()
                Button("New Preset") { isCreating = true }
                    .buttonStyle(EntulePrimaryButtonStyle())
            }

            List {
                ForEach(menuBarViewModel.presets) { preset in
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
                            Task { await menuBarViewModel.launchPreset(preset) }
                        }
                        .buttonStyle(EntuleSecondaryButtonStyle())
                        .disabled(menuBarViewModel.isBusy)
                        Button("Edit") {
                            editingPreset = preset
                        }
                        .buttonStyle(EntuleSecondaryButtonStyle())
                        Button("Delete", role: .destructive) {
                            menuBarViewModel.deletePreset(id: preset.id)
                        }
                        .buttonStyle(EntuleSecondaryButtonStyle())
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .entulePanel()
        }
        .padding()
        .frame(minWidth: 860, minHeight: 620)
        .entuleWindowBackground()
        .background(
            WindowAccessor { window in
                WindowCoordinator.activate(window: window)
            }
        )
        .sheet(item: $editingPreset) { preset in
            PresetEditorView(viewModel: PresetEditorViewModel(preset: preset)) { updated in
                menuBarViewModel.savePreset(updated)
            }
        }
        .sheet(isPresented: $isCreating) {
            PresetEditorView(viewModel: PresetEditorViewModel()) { preset in
                menuBarViewModel.savePreset(preset)
            }
        }
    }
}
