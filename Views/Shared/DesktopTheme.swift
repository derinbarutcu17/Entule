import SwiftUI

enum EntuleTheme {
    static let obsidian = Color(red: 10 / 255, green: 11 / 255, blue: 15 / 255)
    static let graphite = Color(red: 16 / 255, green: 19 / 255, blue: 26 / 255)
    static let ink = Color(red: 20 / 255, green: 25 / 255, blue: 34 / 255)
    static let panelTop = Color(red: 22 / 255, green: 27 / 255, blue: 36 / 255, opacity: 0.92)
    static let panelBottom = Color(red: 15 / 255, green: 18 / 255, blue: 25 / 255, opacity: 0.9)
    static let lineSoft = Color(red: 191 / 255, green: 202 / 255, blue: 224 / 255, opacity: 0.14)
    static let lineWarm = Color(red: 210 / 255, green: 193 / 255, blue: 151 / 255, opacity: 0.2)
    static let moon = Color(red: 202 / 255, green: 211 / 255, blue: 232 / 255)
    static let moonDim = Color(red: 143 / 255, green: 152 / 255, blue: 171 / 255)
    static let amber = Color(red: 207 / 255, green: 176 / 255, blue: 123 / 255)
    static let amberSoft = Color(red: 167 / 255, green: 143 / 255, blue: 104 / 255)
    static let success = Color(red: 156 / 255, green: 207 / 255, blue: 157 / 255)
    static let danger = Color(red: 229 / 255, green: 169 / 255, blue: 169 / 255)

    static let windowGradient = LinearGradient(
        colors: [obsidian, graphite, Color.black.opacity(0.92)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let panelGradient = LinearGradient(
        colors: [panelTop, panelBottom],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let primaryButtonGradient = LinearGradient(
        colors: [
            Color(red: 211 / 255, green: 178 / 255, blue: 127 / 255),
            Color(red: 175 / 255, green: 142 / 255, blue: 93 / 255),
            Color(red: 152 / 255, green: 119 / 255, blue: 72 / 255)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct EntuleWindowBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            EntuleTheme.windowGradient
                .ignoresSafeArea()

            Circle()
                .fill(EntuleTheme.amber.opacity(0.12))
                .frame(width: 320, height: 320)
                .blur(radius: 80)
                .offset(x: -220, y: -220)

            Circle()
                .fill(EntuleTheme.moon.opacity(0.08))
                .frame(width: 360, height: 360)
                .blur(radius: 100)
                .offset(x: 240, y: -180)

            content
        }
        .preferredColorScheme(.dark)
    }
}

struct EntulePanel: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(18)
            .background(EntuleTheme.panelGradient)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(EntuleTheme.lineSoft, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(0.32), radius: 26, y: 14)
    }
}

struct EntulePrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
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
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .opacity(configuration.isPressed ? 0.94 : 1)
    }
}

struct EntuleSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(Color.white.opacity(configuration.isPressed ? 0.09 : 0.05))
            .foregroundStyle(EntuleTheme.moon)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(EntuleTheme.lineWarm, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

extension View {
    func entuleWindowBackground() -> some View {
        modifier(EntuleWindowBackground())
    }

    func entulePanel() -> some View {
        modifier(EntulePanel())
    }
}
