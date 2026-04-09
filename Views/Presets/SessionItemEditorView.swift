import SwiftUI

struct SessionItemEditorView: View {
    @Binding var item: SessionItem

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: AppWindowMetrics.spacingS) {
                typeBadge
                textFields
                selectedToggle
            }

            VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
                HStack(spacing: AppWindowMetrics.spacingS) {
                    typeBadge
                    selectedToggle
                }
                textFields
            }
        }
        .padding(.vertical, AppWindowMetrics.spacingXS)
    }

    private var typeBadge: some View {
        Text(item.kind.rawValue.capitalized)
            .font(EntuleTypography.font(12, weight: .semibold))
            .foregroundStyle(EntuleTheme.inkDim)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.92))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(EntuleTheme.lineSoft, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .frame(minWidth: AppWindowMetrics.pickerMinWidth, alignment: .leading)
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
