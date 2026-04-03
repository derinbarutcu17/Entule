import SwiftUI

struct SessionItemEditorView: View {
    @Binding var item: SessionItem

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: AppWindowMetrics.spacingS) {
                typePicker
                textFields
                selectedToggle
            }

            VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
                HStack(spacing: AppWindowMetrics.spacingS) {
                    typePicker
                    selectedToggle
                }
                textFields
            }
        }
        .padding(.vertical, AppWindowMetrics.spacingXS)
    }

    private var typePicker: some View {
        Picker("Type", selection: $item.kind) {
            ForEach(SessionItemKind.allCases, id: \.self) { kind in
                Text(kind.rawValue.capitalized).tag(kind)
            }
        }
        .frame(minWidth: AppWindowMetrics.pickerMinWidth)
    }

    private var textFields: some View {
        Group {
            TextField("Display Name", text: $item.displayName)
                .entuleInputField()
            TextField("Value", text: $item.value)
                .entuleInputField()
        }
    }

    private var selectedToggle: some View {
        Toggle("Selected", isOn: $item.isSelected)
            .toggleStyle(.switch)
            .frame(minWidth: AppWindowMetrics.toggleMinWidth, alignment: .leading)
    }
}
