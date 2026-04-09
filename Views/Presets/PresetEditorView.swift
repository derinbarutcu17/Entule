import SwiftUI

struct PresetEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: PresetEditorViewModel

    let onSave: (Preset) -> Void

    @State private var newURLText = ""
    @State private var attemptedInvalidSave = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppWindowMetrics.spacingM) {
            VStack(alignment: .leading, spacing: AppWindowMetrics.spacingXS) {
                Text("Preset Editor")
                    .font(EntuleTypography.font(28, weight: .semibold))
                    .foregroundStyle(EntuleTheme.ink)
                Text("Build a reusable launch setup with apps, files, folders, and URLs.")
                    .font(EntuleTypography.font(13))
                    .foregroundStyle(EntuleTheme.inkDim)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: AppWindowMetrics.spacingM) {
                    fieldsPanel
                    itemsPanel
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }

            actionRow
        }
        .padding(AppWindowMetrics.outerPadding)
        .entuleWindowBackground()
        .frame(minWidth: AppWindowMetrics.editorMinWidth, minHeight: AppWindowMetrics.editorMinHeight)
        .onChange(of: viewModel.name) { _ in
            if viewModel.canSave {
                attemptedInvalidSave = false
            }
        }
    }

    private var fieldsPanel: some View {
        VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
            TextField("Preset Name", text: $viewModel.name)
                .entuleInputField()
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(nameFieldInvalid ? EntuleTheme.danger : Color.clear, lineWidth: 1.5)
                }
                .shadow(
                    color: nameFieldInvalid ? EntuleTheme.danger.opacity(0.28) : Color.clear,
                    radius: 10,
                    y: 0
                )

            if nameFieldInvalid {
                Text("Preset name is required.")
                    .font(EntuleTypography.font(12, weight: .medium))
                    .foregroundStyle(EntuleTheme.danger)
            }
            addControls
        }
        .entulePanel()
    }

    private var addControls: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: AppWindowMetrics.spacingS) {
                addButtons

                TextField("Add URL", text: $newURLText)
                    .entuleInputField()
                    .frame(minWidth: AppWindowMetrics.formMinFieldWidth)

                Button("Add URL") { addURL() }
                    .buttonStyle(EntuleSecondaryButtonStyle())
            }

            VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
                addButtons
                HStack(spacing: AppWindowMetrics.spacingS) {
                    TextField("Add URL", text: $newURLText)
                        .entuleInputField()
                    Button("Add URL") { addURL() }
                        .buttonStyle(EntuleSecondaryButtonStyle())
                }
            }
        }
    }

    private var addButtons: some View {
        HStack(spacing: AppWindowMetrics.spacingS) {
            Button("Add App") { viewModel.addAppItems() }
                .buttonStyle(EntuleSecondaryButtonStyle())
            Button("Add File or Folder") { viewModel.addFileItems() }
                .buttonStyle(EntuleSecondaryButtonStyle())
        }
    }

    private var itemsPanel: some View {
        VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
            Text("Items")
                .font(EntuleTypography.font(18, weight: .semibold))
                .foregroundStyle(EntuleTheme.ink)

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
            .listStyle(.plain)
            .frame(minHeight: AppWindowMetrics.listMinHeight)
        }
        .entulePanel()
    }

    private var actionRow: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: AppWindowMetrics.spacingS) {
                Button("Cancel") { dismiss() }
                    .buttonStyle(EntuleSecondaryButtonStyle())
                Spacer(minLength: 0)
                saveButton
            }

            VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
                saveButton
                Button("Cancel") { dismiss() }
                    .buttonStyle(EntuleSecondaryButtonStyle())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var saveButton: some View {
        Button("Save") {
            guard viewModel.canSave else {
                attemptedInvalidSave = true
                return
            }
            onSave(viewModel.toPreset())
            dismiss()
        }
        .buttonStyle(EntulePrimaryButtonStyle())
    }

    private func addURL() {
        viewModel.addURLItem(raw: newURLText)
        newURLText = ""
    }

    private var nameFieldInvalid: Bool {
        attemptedInvalidSave && !viewModel.canSave
    }
}
