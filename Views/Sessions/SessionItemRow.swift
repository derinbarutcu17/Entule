import SwiftUI
import AppKit

struct SessionItemRow: View {
    @Binding var item: SessionItem
    var onRemove: (() -> Void)?

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: AppWindowMetrics.spacingS) {
                rowToggle
                rowIcon
                rowText
                Spacer(minLength: 0)
                rowTrailing
            }
            .padding(.horizontal, 6)

            VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
                HStack(alignment: .center, spacing: AppWindowMetrics.spacingS) {
                    rowToggle
                    rowIcon
                    rowText
                }
                HStack(spacing: AppWindowMetrics.spacingS) {
                    Spacer(minLength: 0)
                    rowTrailing
                }
            }
            .padding(.horizontal, 6)
        }
        .padding(.vertical, AppWindowMetrics.spacingXS)
    }

    private var rowToggle: some View {
        Button {
            item.isSelected.toggle()
        } label: {
            Image(systemName: item.isSelected ? "checkmark.square.fill" : "square")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(item.isSelected ? EntuleTheme.orange : EntuleTheme.inkSoft)
                .frame(width: 22, height: 22, alignment: .center)
        }
        .buttonStyle(.plain)
        .frame(width: 28, height: 28, alignment: .center)
    }

    private var rowIcon: some View {
        Group {
            if let image = resolvedIcon {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: 36, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(EntuleTheme.orangeWash)
                    .frame(width: 36, height: 36)
                    .overlay {
                        Image(systemName: fallbackSymbol)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(EntuleTheme.orange)
                    }
            }
        }
        .frame(width: 36, height: 36)
    }

    private var rowText: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(item.displayName)
                .font(EntuleTypography.font(15, weight: .semibold))
                .foregroundStyle(EntuleTheme.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            if item.kind == .url {
                Text(item.value)
                    .font(EntuleTypography.font(12))
                    .foregroundStyle(EntuleTheme.inkDim)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(minWidth: AppWindowMetrics.sessionValueMinWidth, maxWidth: .infinity, alignment: .leading)
    }

    private var rowTrailing: some View {
        HStack(spacing: AppWindowMetrics.spacingS) {
            removeButton
        }
    }

    @ViewBuilder
    private var removeButton: some View {
        if let onRemove {
            Button("Remove", role: .destructive, action: onRemove)
                .buttonStyle(EntuleSecondaryButtonStyle())
        }
    }

    private var resolvedIcon: NSImage? {
        let cacheKey: String
        switch item.kind {
        case .app:
            if let path = item.appPath, !path.isEmpty {
                cacheKey = "app::\(path)"
            } else {
                return nil
            }
        case .file, .folder:
            cacheKey = "\(item.kind.rawValue)::\(item.value)"
        case .url:
            return nil
        }

        if let cached = SessionItemIconCache.shared.object(forKey: cacheKey as NSString) {
            return cached
        }

        let image = NSWorkspace.shared.icon(forFile: item.kind == .app ? (item.appPath ?? item.value) : item.value)
        SessionItemIconCache.shared.setObject(image, forKey: cacheKey as NSString)
        return image
    }

    private var fallbackSymbol: String {
        switch item.kind {
        case .app:
            return "app.fill"
        case .file:
            return "doc.fill"
        case .folder:
            return "folder.fill"
        case .url:
            return "link"
        }
    }
}

private enum SessionItemIconCache {
    static let shared = NSCache<NSString, NSImage>()
}
