import SwiftUI

enum EntuleTheme {
    static let canvas = Color(red: 249 / 255, green: 247 / 255, blue: 243 / 255)
    static let paper = Color.white
    static let paperWarm = Color(red: 254 / 255, green: 251 / 255, blue: 246 / 255)

    static let ink = Color(red: 18 / 255, green: 18 / 255, blue: 18 / 255)
    static let inkDim = Color(red: 103 / 255, green: 103 / 255, blue: 103 / 255)
    static let inkSoft = Color(red: 138 / 255, green: 138 / 255, blue: 138 / 255)

    static let orange = Color(red: 230 / 255, green: 90 / 255, blue: 8 / 255)
    static let orangeDeep = Color(red: 206 / 255, green: 77 / 255, blue: 8 / 255)
    static let orangeSoft = Color(red: 246 / 255, green: 139 / 255, blue: 76 / 255)
    static let orangeWash = Color(red: 255 / 255, green: 245 / 255, blue: 238 / 255)

    static let lineSoft = Color.black.opacity(0.08)
    static let lineWarm = orange.opacity(0.22)
    static let moon = ink
    static let moonDim = inkDim
    static let amber = orange
    static let amberSoft = orangeSoft
    static let success = Color(red: 20 / 255, green: 132 / 255, blue: 74 / 255)
    static let danger = Color(red: 180 / 255, green: 52 / 255, blue: 30 / 255)

    static let windowGradient = LinearGradient(
        colors: [canvas, paperWarm],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let panelGradient = LinearGradient(
        colors: [paper, paperWarm],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let primaryButtonGradient = LinearGradient(
        colors: [orange, orangeDeep],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

enum EntuleTypography {
    static func font(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font.custom("Manrope", size: size).weight(weight)
    }
}

struct EntuleWindowBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            EntuleTheme.windowGradient
                .ignoresSafeArea()

            Circle()
                .fill(EntuleTheme.orange.opacity(0.05))
                .frame(width: 420, height: 420)
                .blur(radius: 60)
                .offset(x: 220, y: -160)

            Circle()
                .fill(Color.black.opacity(0.03))
                .frame(width: 320, height: 320)
                .blur(radius: 90)
                .offset(x: -280, y: 260)

            content
        }
        .preferredColorScheme(.light)
    }
}

struct EntulePanel: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppWindowMetrics.panelPadding)
            .background(EntuleTheme.panelGradient)
            .overlay(
                RoundedRectangle(cornerRadius: AppWindowMetrics.panelCornerRadius, style: .continuous)
                    .stroke(EntuleTheme.lineSoft, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppWindowMetrics.panelCornerRadius, style: .continuous))
            .shadow(color: Color.black.opacity(0.05), radius: 18, y: 12)
    }
}

struct EntulePrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(EntuleTypography.font(13, weight: .semibold))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(EntuleTheme.primaryButtonGradient)
            .foregroundStyle(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .opacity(configuration.isPressed ? 0.94 : 1)
    }
}

struct EntuleSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(EntuleTypography.font(13, weight: .medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(configuration.isPressed ? EntuleTheme.orangeWash : Color.white.opacity(0.92))
            .foregroundStyle(EntuleTheme.ink)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(EntuleTheme.lineWarm, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct EntuleInputField: ViewModifier {
    func body(content: Content) -> some View {
        content
            .textFieldStyle(.plain)
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(Color.white)
            .foregroundStyle(EntuleTheme.ink)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(EntuleTheme.lineWarm, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

extension View {
    func entuleWindowBackground() -> some View {
        modifier(EntuleWindowBackground())
    }

    func entulePanel() -> some View {
        modifier(EntulePanel())
    }

    func entuleInputField() -> some View {
        modifier(EntuleInputField())
    }
}
