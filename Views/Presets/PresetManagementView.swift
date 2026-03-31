import SwiftUI

struct PresetManagementView: View {
    @ObservedObject var menuBarViewModel: MenuBarViewModel

    @State private var editingPreset: Preset?
    @State private var isCreating = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Presets")
                    .font(.title3.bold())
                Spacer()
                Button("New Preset") { isCreating = true }
            }

            List {
                ForEach(menuBarViewModel.presets) { preset in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(preset.name)
                            Text("\(preset.items.count) items")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button("Launch") {
                            Task { await menuBarViewModel.launchPreset(preset) }
                        }
                        Button("Edit") {
                            editingPreset = preset
                        }
                        Button("Delete", role: .destructive) {
                            menuBarViewModel.deletePreset(id: preset.id)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(minWidth: 600, minHeight: 420)
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
