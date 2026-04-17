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
    private let highlightPadding: CGFloat = 12
    private let tooltipMaxWidth: CGFloat = 420
    private let tooltipMinWidth: CGFloat = 320

    var body: some View {
        GeometryReader { proxy in
            if manager.isActive {
                let step = manager.currentStep
                let targetRect = step.target.flatMap { target in
                    anchors[target].map { proxy[$0] }
                }
                let layout = tooltipLayout(in: proxy.size, targetRect: targetRect, for: step)

                ZStack(alignment: .topLeading) {
                    dimLayer(targetRect: targetRect)
                        .contentShape(Rectangle())
                        .onTapGesture { }

                    if let targetRect {
                        tutorialArrow(from: layout.arrowStart, to: CGPoint(x: targetRect.midX, y: targetRect.midY))
                            .stroke(Color.white.opacity(0.95), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    }

                    tooltipCard(step: step)
                        .frame(width: layout.tooltipWidth)
                        .position(layout.tooltipCenter)

                    debugAnchorOverlay(targetRect)
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
                    RoundedRectangle(cornerRadius: max(12, min(targetRect.height, targetRect.width) * 0.2), style: .continuous)
                        .frame(
                            width: targetRect.width + highlightPadding * 2,
                            height: targetRect.height + highlightPadding * 2
                        )
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

    @ViewBuilder
    private func debugAnchorOverlay(_ targetRect: CGRect?) -> some View {
        if ProcessInfo.processInfo.environment["ENTULE_TUTORIAL_DEBUG"] == "1", let targetRect {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.cyan, style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                .frame(width: targetRect.width, height: targetRect.height)
                .position(x: targetRect.midX, y: targetRect.midY)
        }
    }

    private func tutorialArrow(from start: CGPoint, to end: CGPoint) -> Path {
        var path = Path()
        path.move(to: start)
        path.addLine(to: end)

        let angle = atan2(end.y - start.y, end.x - start.x)
        let arrowLength: CGFloat = 12
        let arrowAngle: CGFloat = .pi / 7

        let p1 = CGPoint(
            x: end.x - arrowLength * cos(angle - arrowAngle),
            y: end.y - arrowLength * sin(angle - arrowAngle)
        )
        let p2 = CGPoint(
            x: end.x - arrowLength * cos(angle + arrowAngle),
            y: end.y - arrowLength * sin(angle + arrowAngle)
        )

        path.move(to: end)
        path.addLine(to: p1)
        path.move(to: end)
        path.addLine(to: p2)
        return path
    }

    private enum TooltipPlacement {
        case above, below, leading, trailing, centered
    }

    private func tooltipLayout(in size: CGSize, targetRect: CGRect?, for step: TutorialStep) -> (tooltipCenter: CGPoint, arrowStart: CGPoint, tooltipWidth: CGFloat) {
        let tooltipWidth = min(max(size.width * 0.34, tooltipMinWidth), tooltipMaxWidth)
        let tooltipHeight: CGFloat = step == .welcome ? 176 : 164

        guard let targetRect, step.target != nil else {
            let center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
            return (center, center, tooltipWidth)
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
            return (CGPoint(x: x, y: y), CGPoint(x: x, y: y - (tooltipHeight / 2) - 12), tooltipWidth)
        case .above:
            let x = min(max(targetRect.midX, (tooltipWidth / 2) + margin), size.width - (tooltipWidth / 2) - margin)
            let y = max((tooltipHeight / 2) + margin, targetRect.minY - gap - (tooltipHeight / 2))
            return (CGPoint(x: x, y: y), CGPoint(x: x, y: y + (tooltipHeight / 2) + 12), tooltipWidth)
        case .trailing:
            let x = min(size.width - (tooltipWidth / 2) - margin, targetRect.maxX + gap + (tooltipWidth / 2))
            let y = min(max(targetRect.midY, (tooltipHeight / 2) + margin), size.height - (tooltipHeight / 2) - margin)
            return (CGPoint(x: x, y: y), CGPoint(x: x - (tooltipWidth / 2) - 12, y: y), tooltipWidth)
        case .leading:
            let x = max((tooltipWidth / 2) + margin, targetRect.minX - gap - (tooltipWidth / 2))
            let y = min(max(targetRect.midY, (tooltipHeight / 2) + margin), size.height - (tooltipHeight / 2) - margin)
            return (CGPoint(x: x, y: y), CGPoint(x: x + (tooltipWidth / 2) + 12, y: y), tooltipWidth)
        case .centered:
            let center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
            return (center, center, tooltipWidth)
        }
    }
}
