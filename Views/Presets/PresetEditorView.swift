import SwiftUI

struct PresetEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: PresetEditorViewModel

    let onSave: (Preset) -> Void

    @State private var newURLText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Preset Name", text: $viewModel.name)
            TextField("Shortcut Name (optional)", text: $viewModel.shortcutName)

            HStack {
                Button("Add App") { viewModel.addAppItems() }
                Button("Add File/Folder") { viewModel.addFileItems() }

                TextField("Add URL", text: $newURLText)
                Button("Add URL") {
                    viewModel.addURLItem(raw: newURLText)
                    newURLText = ""
                }
            }

            List {
                ForEach($viewModel.items) { $item in
                    SessionItemEditorView(item: $item)
                }
                .onDelete(perform: viewModel.removeItems)
                .onMove(perform: viewModel.moveItems)
            }
            .frame(minHeight: 280)

            HStack {
                Button("Cancel") { dismiss() }
                Spacer()
                Button("Save") {
                    onSave(viewModel.toPreset())
                    dismiss()
                }
                .disabled(!viewModel.canSave)
            }
        }
        .padding()
        .frame(minWidth: 760, minHeight: 460)
    }
}
