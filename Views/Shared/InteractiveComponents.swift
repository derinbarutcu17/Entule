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
                        .font(.system(size: 13, weight: .semibold))
                    Text(section.subtitle)
                        .font(.system(size: 11))
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
        .foregroundStyle(isActive ? EntuleTheme.moon : EntuleTheme.moonDim)
        .onHover(perform: onHover)
    }

    private var backgroundFill: Color {
        if isActive { return Color.white.opacity(0.08) }
        if isHovered { return Color.white.opacity(0.045) }
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
    let height: CGFloat

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(EntuleTheme.moon)

                Text(detail)
                    .font(.system(size: 13))
                    .foregroundStyle(EntuleTheme.moonDim)

                Spacer(minLength: 0)

                HStack {
                    if isPrimary {
                        Text(actionTitle)
                            .font(.system(size: 13, weight: .semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(EntuleTheme.primaryButtonGradient)
                            .foregroundStyle(Color.black.opacity(0.88))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    } else {
                        Text(actionTitle)
                            .font(.system(size: 13, weight: .medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(Color.white.opacity(0.05))
                            .foregroundStyle(EntuleTheme.moon)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(EntuleTheme.lineWarm, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, minHeight: height, maxHeight: height, alignment: .topLeading)
            .entulePanel()
            .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

struct CopyValueButton: View {
    let value: String
    let label: String

    var body: some View {
        Button(action: copyValue) {
            Image(systemName: "doc.on.doc")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(EntuleTheme.moonDim)
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.04))
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
