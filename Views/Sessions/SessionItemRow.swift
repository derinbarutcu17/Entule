import SwiftUI

struct SessionItemRow: View {
    @Binding var item: SessionItem
    var onRemove: (() -> Void)?

    var body: some View {
        HStack {
            Toggle("", isOn: $item.isSelected)
                .frame(width: 28)

            Text(item.kind.rawValue.uppercased())
                .font(.caption)
                .foregroundStyle(EntuleTheme.moonDim)
                .frame(width: 60, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.displayName)
                    .foregroundStyle(EntuleTheme.moon)
                Text(item.value)
                    .font(.caption)
                    .foregroundStyle(EntuleTheme.moonDim)
            }

            Spacer()

            Text(item.source)
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(EntuleTheme.orangeWash)
                .foregroundStyle(EntuleTheme.orange)
                .overlay(
                    Capsule()
                        .stroke(EntuleTheme.lineWarm, lineWidth: 1)
                )
                .clipShape(Capsule())

            if let onRemove {
                Button("Remove", role: .destructive, action: onRemove)
                    .buttonStyle(EntuleSecondaryButtonStyle())
            }
        }
        .padding(.vertical, 4)
    }
}
