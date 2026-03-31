import SwiftUI

struct SessionItemEditorView: View {
    @Binding var item: SessionItem

    var body: some View {
        HStack {
            Picker("Type", selection: $item.kind) {
                ForEach(SessionItemKind.allCases, id: \.self) { kind in
                    Text(kind.rawValue.capitalized).tag(kind)
                }
            }
            .frame(width: 110)

            TextField("Display Name", text: $item.displayName)
            TextField("Value", text: $item.value)
            Toggle("Selected", isOn: $item.isSelected)
                .toggleStyle(.switch)
                .frame(width: 90)
        }
    }
}
