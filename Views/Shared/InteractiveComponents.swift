import AppKit
import SwiftUI

struct SidebarNavItem: View {
    let section: AppSection
    let isActive: Bool
    let isHovered: Bool
    let action: () -> Void
    let onHover: (Bool) -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: section.symbolName)
                    .frame(width: 18)
                VStack(alignment: .leading, spacing: 2) {
                    Text(section.title)
                        .font(EntuleTypography.font(13, weight: .semibold))
                    Text(section.subtitle)
                        .font(EntuleTypography.font(11))
                        .lineLimit(1)
                        .opacity(0.78)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(backgroundFill)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(borderColor, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .foregroundStyle(isActive ? EntuleTheme.ink : EntuleTheme.inkDim)
        .onHover(perform: onHover)
    }

    private var backgroundFill: Color {
        if isActive { return EntuleTheme.orangeWash }
        if isHovered { return Color.white.opacity(0.8) }
        return .clear
    }

    private var borderColor: Color {
        if isActive { return EntuleTheme.lineWarm }
        if isHovered { return EntuleTheme.lineSoft }
        return .clear
    }
}

struct ActionCardButton: View {
    let title: String
    let detail: String
    let actionTitle: String
    let isPrimary: Bool
    let isDisabled: Bool
    let action: () -> Void
    let minHeight: CGFloat

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
                Text(title)
                    .font(EntuleTypography.font(18, weight: .semibold))
                    .foregroundStyle(EntuleTheme.ink)
                    .fixedSize(horizontal: false, vertical: true)

                Text(detail)
                    .font(EntuleTypography.font(13))
                    .foregroundStyle(EntuleTheme.inkDim)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)

                HStack {
                    Text(actionTitle)
                        .font(EntuleTypography.font(13, weight: .semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(isPrimary ? AnyShapeStyle(EntuleTheme.primaryButtonGradient) : AnyShapeStyle(Color.white))
                        .foregroundStyle(isPrimary ? AnyShapeStyle(Color.white) : AnyShapeStyle(EntuleTheme.ink))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(isPrimary ? Color.clear : EntuleTheme.lineWarm, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
            .entulePanel()
            .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

struct FloatingSectionButton: View {
    let section: AppSection
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: section.symbolName)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 18, height: 18)

                if isActive {
                    Text(shortLabel)
                        .font(EntuleTypography.font(14, weight: .medium))
                        .lineLimit(1)
                }
            }
            .foregroundStyle(Color.white)
            .padding(.horizontal, isActive ? 18 : 0)
            .frame(
                width: isActive ? AppWindowMetrics.floatingDockActiveWidth : AppWindowMetrics.floatingDockCircleSize,
                height: AppWindowMetrics.floatingDockCircleSize
            )
            .background(EntuleTheme.primaryButtonGradient)
            .clipShape(Capsule())
            .contentShape(Capsule())
            .shadow(color: EntuleTheme.orange.opacity(0.18), radius: 12, y: 8)
        }
        .buttonStyle(.plain)
    }

    private var shortLabel: String {
        switch section {
        case .home: return "Home"
        case .saveSession: return "Save"
        case .inspectCheckpoint: return "Inspect"
        case .presets: return "Presets"
        case .settings: return "Settings"
        }
    }
}

struct HomeUtilityButton<Label: View>: View {
    let width: CGFloat
    let height: CGFloat
    let action: () -> Void
    let label: Label

    @State private var isHovered = false

    init(width: CGFloat, height: CGFloat, action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.width = width
        self.height = height
        self.action = action
        self.label = label()
    }

    var body: some View {
        Button(action: action) {
            label
                .frame(width: width, height: height)
                .background(EntuleTheme.primaryButtonGradient)
                .foregroundStyle(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .scaleEffect(isHovered ? 1.03 : 1)
                .shadow(color: EntuleTheme.orange.opacity(isHovered ? 0.24 : 0.18), radius: isHovered ? 18 : 12, y: isHovered ? 10 : 8)
                .contentShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .animation(.easeOut(duration: 0.18), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct CopyValueButton: View {
    let value: String
    let label: String

    var body: some View {
        Button(action: copyValue) {
            Image(systemName: "doc.on.doc")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(EntuleTheme.inkDim)
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(EntuleTheme.lineSoft, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .help("Copy \(label)")
    }

    private func copyValue() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(value, forType: .string)
    }
}
