import SwiftUI

struct PresetEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: PresetEditorViewModel

    let onSave: (Preset) -> Void

    @State private var newURLText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Preset Editor")
                    .font(.system(size: 26, weight: .semibold, design: .rounded))
                    .foregroundStyle(EntuleTheme.moon)
                Text("Build a reusable launch setup with apps, files, folders, and URLs.")
                    .font(.caption)
                    .foregroundStyle(EntuleTheme.moonDim)
            }

            TextField("Preset Name", text: $viewModel.name)
                .textFieldStyle(.roundedBorder)
            TextField("Shortcut Name (optional)", text: $viewModel.shortcutName)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("Add App") { viewModel.addAppItems() }
                    .buttonStyle(EntuleSecondaryButtonStyle())
                Button("Add File/Folder") { viewModel.addFileItems() }
                    .buttonStyle(EntuleSecondaryButtonStyle())

                TextField("Add URL", text: $newURLText)
                    .textFieldStyle(.roundedBorder)
                Button("Add URL") {
                    viewModel.addURLItem(raw: newURLText)
                    newURLText = ""
                }
                .buttonStyle(EntuleSecondaryButtonStyle())
            }

            List {
                ForEach($viewModel.items) { $item in
                    SessionItemEditorView(item: $item)
                        .listRowBackground(Color.clear)
                }
                .onDelete(perform: viewModel.removeItems)
                .onMove(perform: viewModel.moveItems)
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .frame(minHeight: 280)
            .entulePanel()

            HStack {
                Button("Cancel") { dismiss() }
                    .buttonStyle(EntuleSecondaryButtonStyle())
                Spacer()
                Button("Save") {
                    onSave(viewModel.toPreset())
                    dismiss()
                }
                .buttonStyle(EntulePrimaryButtonStyle())
                .disabled(!viewModel.canSave)
            }
        }
        .padding()
        .entuleWindowBackground()
        .frame(minWidth: 760, minHeight: 460)
    }
}
