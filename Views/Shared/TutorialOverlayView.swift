import SwiftUI

struct TutorialBoundsKey: PreferenceKey {
    static var defaultValue: [TutorialTarget: Anchor<CGRect>] = [:]

    static func reduce(value: inout [TutorialTarget: Anchor<CGRect>], nextValue: () -> [TutorialTarget: Anchor<CGRect>]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

extension View {
    func tutorialAnchor(_ target: TutorialTarget) -> some View {
        anchorPreference(key: TutorialBoundsKey.self, value: .bounds) { [target: $0] }
    }
}

struct HelpButtonView: View {
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: "questionmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(EntuleTheme.ink)
                .frame(width: 24, height: 24)
                .background(Color.white.opacity(0.94))
                .overlay(
                    Circle()
                        .stroke(EntuleTheme.lineWarm, lineWidth: 1)
                )
                .clipShape(Circle())
                .scaleEffect(isHovered ? 1.04 : 1)
                .shadow(color: Color.black.opacity(isHovered ? 0.09 : 0.05), radius: isHovered ? 8 : 5, y: isHovered ? 5 : 3)
                .animation(.easeOut(duration: 0.16), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
        .help("How to use Entule")
        .accessibilityLabel("Start tutorial")
    }
}

struct TutorialOverlayView: View {
    @ObservedObject var manager: TutorialManager
    let anchors: [TutorialTarget: Anchor<CGRect>]
    private let tooltipMaxWidth: CGFloat = 420
    private let tooltipMinWidth: CGFloat = 320

    var body: some View {
        GeometryReader { proxy in
            if manager.isActive {
                let step = manager.currentStep
                let targetRect = focusedRect(for: step, in: proxy)
                let layout = tooltipLayout(in: proxy.size, targetRect: targetRect, for: step)

                ZStack(alignment: .topLeading) {
                    dimLayer(targetRect: targetRect)
                        .contentShape(Rectangle())
                        .onTapGesture { }

                    tooltipCard(step: step)
                        .frame(width: layout.tooltipWidth)
                        .position(layout.tooltipCenter)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .transition(.opacity)
                .zIndex(9999)
            }
        }
        .allowsHitTesting(manager.isActive)
        .animation(.easeOut(duration: 0.18), value: manager.currentStep)
        .animation(.easeOut(duration: 0.18), value: manager.isActive)
    }

    @ViewBuilder
    private func dimLayer(targetRect: CGRect?) -> some View {
        Color.black.opacity(0.58)
            .overlay {
                if let targetRect {
                    let padding = manager.currentStep.target?.spotlightPadding ?? 6
                    let haloWidth = targetRect.width + (padding * 6)
                    let haloHeight = targetRect.height + (padding * 6)
                    let corner = max(12, min(targetRect.height, targetRect.width) * 0.28)

                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .fill(Color.black.opacity(0.88))
                        .frame(width: haloWidth, height: haloHeight)
                        .blur(radius: 26)
                        .position(x: targetRect.midX, y: targetRect.midY)
                        .blendMode(.destinationOut)

                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .fill(Color.black.opacity(0.46))
                        .frame(width: haloWidth * 0.88, height: haloHeight * 0.88)
                        .blur(radius: 12)
                        .position(x: targetRect.midX, y: targetRect.midY)
                        .blendMode(.destinationOut)
                }
            }
            .compositingGroup()
            .ignoresSafeArea()
    }

    private func tooltipCard(step: TutorialStep) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(step.title)
                .font(EntuleTypography.font(18, weight: .bold))
                .foregroundStyle(EntuleTheme.ink)

            Text(step.message)
                .font(EntuleTypography.font(13, weight: .medium))
                .foregroundStyle(EntuleTheme.inkDim)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                Button("Skip") {
                    manager.skipTutorial()
                }
                .buttonStyle(EntuleSecondaryButtonStyle())

                Spacer(minLength: 0)

                Button(step == .settingsDone ? "Done" : "Next") {
                    manager.nextStep()
                }
                .buttonStyle(EntulePrimaryButtonStyle())
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.98))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(EntuleTheme.lineSoft, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.22), radius: 24, y: 14)
    }

    private func focusedRect(for step: TutorialStep, in proxy: GeometryProxy) -> CGRect? {
        guard let target = step.target, let anchor = anchors[target] else { return nil }
        var rect = proxy[anchor]
        rect.origin.y += target.spotlightYOffset
        return rect
    }

    private enum TooltipPlacement {
        case above, below, leading, trailing, centered
    }

    private func tooltipLayout(in size: CGSize, targetRect: CGRect?, for step: TutorialStep) -> (tooltipCenter: CGPoint, tooltipWidth: CGFloat) {
        let tooltipWidth = min(max(size.width * 0.34, tooltipMinWidth), tooltipMaxWidth)
        let tooltipHeight: CGFloat = step == .welcome ? 176 : 164

        guard let targetRect, step.target != nil else {
            let center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
            return (center, tooltipWidth)
        }

        let margin: CGFloat = 24
        let gap: CGFloat = max(16, targetRect.height * 0.8)

        let spaceAbove = targetRect.minY - margin
        let spaceBelow = size.height - targetRect.maxY - margin
        let spaceLeading = targetRect.minX - margin
        let spaceTrailing = size.width - targetRect.maxX - margin

        let placement: TooltipPlacement = {
            if spaceBelow >= tooltipHeight + gap { return .below }
            if spaceAbove >= tooltipHeight + gap { return .above }
            if spaceTrailing >= tooltipWidth + gap { return .trailing }
            if spaceLeading >= tooltipWidth + gap { return .leading }
            return .centered
        }()

        switch placement {
        case .below:
            let x = min(max(targetRect.midX, (tooltipWidth / 2) + margin), size.width - (tooltipWidth / 2) - margin)
            let y = min(size.height - (tooltipHeight / 2) - margin, targetRect.maxY + gap + (tooltipHeight / 2))
            return (CGPoint(x: x, y: y), tooltipWidth)
        case .above:
            let x = min(max(targetRect.midX, (tooltipWidth / 2) + margin), size.width - (tooltipWidth / 2) - margin)
            let y = max((tooltipHeight / 2) + margin, targetRect.minY - gap - (tooltipHeight / 2))
            return (CGPoint(x: x, y: y), tooltipWidth)
        case .trailing:
            let x = min(size.width - (tooltipWidth / 2) - margin, targetRect.maxX + gap + (tooltipWidth / 2))
            let y = min(max(targetRect.midY, (tooltipHeight / 2) + margin), size.height - (tooltipHeight / 2) - margin)
            return (CGPoint(x: x, y: y), tooltipWidth)
        case .leading:
            let x = max((tooltipWidth / 2) + margin, targetRect.minX - gap - (tooltipWidth / 2))
            let y = min(max(targetRect.midY, (tooltipHeight / 2) + margin), size.height - (tooltipHeight / 2) - margin)
            return (CGPoint(x: x, y: y), tooltipWidth)
        case .centered:
            let center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
            return (center, tooltipWidth)
        }
    }
}
