import SwiftUI

struct SessionItemRow: View {
    @Binding var item: SessionItem
    var onRemove: (() -> Void)?

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: AppWindowMetrics.spacingS) {
                rowToggle
                rowKind
                rowText
                Spacer(minLength: 0)
                rowTrailing
            }

            VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
                HStack(alignment: .top, spacing: AppWindowMetrics.spacingS) {
                    rowToggle
                    rowKind
                    rowText
                }
                HStack(spacing: AppWindowMetrics.spacingS) {
                    Spacer(minLength: 0)
                    rowTrailing
                }
            }
        }
        .padding(.vertical, AppWindowMetrics.spacingXS)
    }

    private var rowToggle: some View {
        Toggle("", isOn: $item.isSelected)
            .labelsHidden()
            .frame(width: 28, alignment: .leading)
    }

    private var rowKind: some View {
        Text(item.kind.rawValue.uppercased())
            .font(EntuleTypography.font(11, weight: .semibold))
            .foregroundStyle(EntuleTheme.inkDim)
            .frame(minWidth: AppWindowMetrics.sessionKindMinWidth, alignment: .leading)
    }

    private var rowText: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.displayName)
                .font(EntuleTypography.font(14, weight: .medium))
                .foregroundStyle(EntuleTheme.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            Text(item.value)
                .font(EntuleTypography.font(12))
                .foregroundStyle(EntuleTheme.inkDim)
                .lineLimit(2)
                .truncationMode(.middle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(minWidth: AppWindowMetrics.sessionValueMinWidth, maxWidth: .infinity, alignment: .leading)
    }

    private var rowTrailing: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: AppWindowMetrics.spacingS) {
                sourceBadge
                removeButton
            }

            VStack(alignment: .trailing, spacing: AppWindowMetrics.spacingXS) {
                sourceBadge
                removeButton
            }
        }
    }

    private var sourceBadge: some View {
        Text(item.source)
            .font(EntuleTypography.font(11, weight: .semibold))
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(EntuleTheme.orangeWash)
            .foregroundStyle(EntuleTheme.orange)
            .overlay(
                Capsule()
                    .stroke(EntuleTheme.lineWarm, lineWidth: 1)
            )
            .clipShape(Capsule())
    }

    @ViewBuilder
    private var removeButton: some View {
        if let onRemove {
            Button("Remove", role: .destructive, action: onRemove)
                .buttonStyle(EntuleSecondaryButtonStyle())
        }
    }
}
