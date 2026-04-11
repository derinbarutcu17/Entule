import AppKit
import SwiftUI

struct EntuleDashboardView: View {
    @ObservedObject var appShellViewModel: AppShellViewModel
    @ObservedObject var workspaceViewModel: WorkspaceViewModel
    @State private var isQuickSaveHovered = false

    var body: some View {
        GeometryReader { proxy in
            let contentSize = CGSize(
                width: max(proxy.size.width - (AppWindowMetrics.outerPadding * 2), 0),
                height: max(proxy.size.height - AppWindowMetrics.titlebarTopInset - AppWindowMetrics.outerPadding, 0)
            )

            VStack(alignment: .leading, spacing: AppWindowMetrics.shellHeaderBottomSpacing) {
                homeTopShell
                    .frame(maxWidth: .infinity, alignment: .center)

                shellContent(for: contentSize)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .padding(.top, AppWindowMetrics.titlebarTopInset)
            .padding(.horizontal, AppWindowMetrics.outerPadding)
            .padding(.bottom, AppWindowMetrics.outerPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .entuleWindowBackground()
    }

    private func shellContent(for contentSize: CGSize) -> some View {
        Group {
            if appShellViewModel.activeSection == .home {
                homeScene(in: contentSize)
            } else {
                secondaryScene
            }
        }
    }

    private func homeScene(in size: CGSize) -> some View {
        let compact = size.width < 900
        let saveSize = heroOrbSize(for: size.width, primary: true, compact: compact)
        let resumeSize = heroOrbSize(for: size.width, primary: false, compact: compact)
        let contentSpacing = min(max(size.width * 0.04, 28), 68)
        let topSpacing = size.height < 690 ? 26.0 : 40.0

        return VStack(spacing: 0) {
            Spacer(minLength: topSpacing)

            heroComposition(saveSize: saveSize, resumeSize: resumeSize, spacing: contentSpacing)
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer(minLength: 40)

            summaryStrip
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var homeTopShell: some View {
        HStack(spacing: AppWindowMetrics.spacingM) {
            Text("Entule")
                .font(EntuleTypography.font(26, weight: .bold))
                .foregroundStyle(EntuleTheme.ink)

            Spacer(minLength: 0)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: AppWindowMetrics.spacingS) {
                    topNavigationButton(title: "Home", section: .home)
                    topNavigationButton(title: "Save", section: .saveSession)
                    if workspaceViewModel.lastSnapshot != nil {
                        topNavigationButton(title: "Inspect", section: .inspectCheckpoint)
                    }
                    topNavigationButton(title: "Presets", section: .presets)
                    topNavigationButton(title: "Settings", section: .settings)
                }

                VStack(alignment: .trailing, spacing: AppWindowMetrics.spacingS) {
                    HStack(spacing: AppWindowMetrics.spacingS) {
                        topNavigationButton(title: "Home", section: .home)
                        topNavigationButton(title: "Save", section: .saveSession)
                        if workspaceViewModel.lastSnapshot != nil {
                            topNavigationButton(title: "Inspect", section: .inspectCheckpoint)
                        }
                    }
                    HStack(spacing: AppWindowMetrics.spacingS) {
                        topNavigationButton(title: "Presets", section: .presets)
                        topNavigationButton(title: "Settings", section: .settings)
                    }
                }
            }
        }
        .padding(.horizontal, 26)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.76))
        .overlay(
            Capsule()
                .stroke(EntuleTheme.lineSoft, lineWidth: 1)
        )
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.04), radius: 18, y: 12)
        .frame(maxWidth: 980)
    }

    private func heroComposition(saveSize: CGFloat, resumeSize: CGFloat, spacing: CGFloat) -> some View {
        HStack(alignment: .center, spacing: spacing) {
            ZStack(alignment: .bottomLeading) {
                homeHeroOrb(
                    title: "Save Session",
                    icon: .assetPNG("one-point-circle"),
                    size: saveSize,
                    subtitle: nil,
                    style: .primary,
                    titleLineSpacing: -6,
                    disabled: workspaceViewModel.isBusy,
                    action: { appShellViewModel.showSaveSession() }
                )

                quickSaveOrb
                    .offset(x: -62, y: 64)
            }

            homeHeroOrb(
                title: "Resume Session",
                icon: .system("arrow.clockwise"),
                size: resumeSize,
                subtitle: workspaceViewModel.canResumeLastSession ? itemCountLabel : "No checkpoint yet",
                style: .secondary,
                titleLineSpacing: 0,
                disabled: !workspaceViewModel.canResumeLastSession,
                action: { Task { _ = await workspaceViewModel.resumeLastSnapshot() } }
            )
        }
    }

    private func homeHeroOrb(
        title: String,
        icon: HomeHeroIcon,
        size: CGFloat,
        subtitle: String?,
        style: HomeHeroOrbStyle,
        titleLineSpacing: CGFloat,
        disabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        HomeHeroOrb(
            title: title,
            icon: icon,
            size: size,
            subtitle: subtitle,
            style: style,
            titleLineSpacing: titleLineSpacing,
            disabled: disabled,
            action: action
        )
    }

    private var summaryStrip: some View {
        HStack(spacing: AppWindowMetrics.spacingM) {
            summaryLabel(systemImage: "clock", text: lastSaveInlineLabel)
            summaryDivider
            if shouldShowSessionName {
                summaryLabel(systemImage: "text.bubble", text: sessionNameLabel)
                summaryDivider
            }
            Button {
                appShellViewModel.inspectCheckpoint()
            } label: {
                summaryLabel(systemImage: "shippingbox", text: itemCountLabel)
            }
            .buttonStyle(.plain)
            .disabled(workspaceViewModel.lastSnapshot == nil)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.74))
        .overlay(
            Capsule()
                .stroke(EntuleTheme.lineSoft, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 999, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 16, y: 10)
    }

    private func summaryLabel(systemImage: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(EntuleTheme.orange)
            Text(text)
                .font(EntuleTypography.font(13, weight: .semibold))
                .foregroundStyle(EntuleTheme.inkDim)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
    }

    private var summaryDivider: some View {
        Circle()
            .fill(EntuleTheme.lineSoft)
            .frame(width: 4, height: 4)
    }

    private func topNavigationButton(title: String, section: AppSection) -> some View {
        TopNavigationButton(
            title: title,
            isActive: appShellViewModel.activeSection == section,
            action: { appShellViewModel.navigate(to: section) }
        )
    }

    private var secondaryScene: some View {
        activeSectionPage
            .frame(maxWidth: AppWindowMetrics.shellContentMaxWidth, alignment: .topLeading)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var activeSectionPage: some View {
        Group {
            switch appShellViewModel.activeSection {
            case .home:
                EmptyView()
            case .saveSession:
                SaveSessionSheet(
                    viewModel: SaveSessionViewModel(),
                    workspaceViewModel: workspaceViewModel,
                    onClose: { appShellViewModel.showHome() }
                )
            case .inspectCheckpoint:
                if let snapshot = workspaceViewModel.lastSnapshot {
                    ResumeSessionSheet(
                        viewModel: ResumeSessionViewModel(snapshot: snapshot),
                        workspaceViewModel: workspaceViewModel
                    )
                } else {
                    emptyState(
                        title: "No checkpoint saved yet",
                        message: "Save a session first, then come back here to inspect it or resume it."
                    )
                }
            case .presets:
                PresetManagementView(workspaceViewModel: workspaceViewModel)
            case .settings:
                SettingsView(workspaceViewModel: workspaceViewModel)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var lastSaveInlineLabel: String {
        guard let snapshot = workspaceViewModel.lastSnapshot else { return "No checkpoint yet" }
        return snapshot.createdAt.formatted(date: .abbreviated, time: .shortened)
    }

    private var itemCountLabel: String {
        let count = workspaceViewModel.lastSnapshot?.items.count ?? 0
        return count == 1 ? "1 item" : "\(count) items"
    }

    private var sessionNameLabel: String {
        guard let snapshot = workspaceViewModel.lastSnapshot else { return "No session name" }
        let trimmed = snapshot.note.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Untitled session" : trimmed
    }

    private var shouldShowSessionName: Bool {
        workspaceViewModel.lastSnapshot?.hasUserProvidedName == true
    }

    private var quickSaveOrb: some View {
        Button {
            Task { _ = await workspaceViewModel.quickSaveCurrentSession() }
        } label: {
            Circle()
                .fill(EntuleTheme.primaryButtonGradient)
                .frame(width: 101, height: 101)
                .overlay {
                    VStack(spacing: 5) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Quick Save")
                            .font(EntuleTypography.font(11, weight: .bold))
                            .multilineTextAlignment(.center)
                    }
                    .foregroundStyle(Color.white)
                }
                .scaleEffect(isQuickSaveHovered ? 1.04 : 1)
                .shadow(
                    color: EntuleTheme.orange.opacity(isQuickSaveHovered ? 0.26 : 0.2),
                    radius: isQuickSaveHovered ? 16 : 12,
                    y: isQuickSaveHovered ? 11 : 8
                )
                .animation(.easeOut(duration: 0.16), value: isQuickSaveHovered)
        }
        .buttonStyle(.plain)
        .disabled(workspaceViewModel.isBusy)
        .accessibilityLabel("Quick Save Session")
        .onHover { hovering in
            isQuickSaveHovered = hovering
        }
    }

    private func emptyState(title: String, message: String) -> some View {
        VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
            Text(title)
                .font(EntuleTypography.font(24, weight: .semibold))
                .foregroundStyle(EntuleTheme.ink)
            Text(message)
                .font(EntuleTypography.font(14))
                .foregroundStyle(EntuleTheme.inkDim)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .entulePanel()
    }

    private func heroOrbSize(for width: CGFloat, primary: Bool, compact: Bool) -> CGFloat {
        if primary {
            return min(max(compact ? width * 0.32 : width * 0.28, 240), 360)
        }
        return min(max(compact ? width * 0.26 : width * 0.22, 210), 310)
    }
}

private struct TopNavigationButton: View {
    let title: String
    let isActive: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(EntuleTypography.font(13, weight: .semibold))
                .foregroundStyle(isActive ? Color.white : EntuleTheme.ink)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(backgroundFill)
                .overlay(
                    Capsule()
                        .stroke(isActive ? Color.clear : EntuleTheme.lineWarm, lineWidth: 1)
                )
                .clipShape(Capsule())
                .scaleEffect(isHovered ? 1.02 : 1)
                .shadow(color: shadowColor, radius: isHovered ? 14 : 10, y: isHovered ? 9 : 6)
                .animation(.easeOut(duration: 0.16), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }

    private var backgroundFill: some ShapeStyle {
        if isActive {
            return AnyShapeStyle(EntuleTheme.primaryButtonGradient)
        }

        return AnyShapeStyle(isHovered ? EntuleTheme.orangeWash : Color.white.opacity(0.92))
    }

    private var shadowColor: Color {
        if isActive {
            return EntuleTheme.orange.opacity(isHovered ? 0.22 : 0.16)
        }

        return Color.black.opacity(isHovered ? 0.05 : 0.03)
    }
}

private enum HomeHeroOrbStyle {
    case primary
    case secondary
}

private enum HomeHeroIcon {
    case system(String)
    case assetPNG(String)
}

private struct HomeHeroOrb: View {
    let title: String
    let icon: HomeHeroIcon
    let size: CGFloat
    let subtitle: String?
    let style: HomeHeroOrbStyle
    let titleLineSpacing: CGFloat
    let disabled: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 14) {
            Button(action: action) {
                Circle()
                    .fill(backgroundFill)
                    .overlay(
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.white.opacity(style == .primary ? 0.18 : 0.10), Color.clear],
                                    center: .topLeading,
                                    startRadius: 8,
                                    endRadius: size * 0.78
                                )
                            )
                            .blendMode(.screen)
                    )
                    .overlay(
                        Circle()
                            .stroke(borderColor, lineWidth: 1)
                    )
                    .overlay {
                        VStack(spacing: size * 0.035) {
                            iconView
                            Text(title)
                                .font(EntuleTypography.font(textSize, weight: .bold))
                                .lineSpacing(titleLineSpacing)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(textColor)
                                .lineLimit(2)
                                .minimumScaleFactor(0.72)
                        }
                        .padding(size * 0.16)
                    }
                    .frame(width: size, height: size)
                    .scaleEffect(isHovered && !disabled ? 1.03 : 1)
                    .opacity(disabled ? 0.45 : 1)
                    .shadow(color: shadowColor, radius: isHovered ? 24 : 16, y: isHovered ? 14 : 10)
                    .animation(.easeOut(duration: 0.18), value: isHovered)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(disabled)
            .onHover { hovering in
                isHovered = hovering
            }

            if let subtitle {
                Text(subtitle)
                    .font(EntuleTypography.font(12, weight: .semibold))
                    .foregroundStyle(EntuleTheme.inkDim)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .frame(width: max(size * 0.82, 180))
            }
        }
    }

    private var backgroundFill: some ShapeStyle {
        switch style {
        case .primary:
            return AnyShapeStyle(EntuleTheme.primaryButtonGradient)
        case .secondary:
            return AnyShapeStyle(Color.white.opacity(0.96))
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary:
            return Color.white.opacity(isHovered ? 0.22 : 0.12)
        case .secondary:
            return EntuleTheme.lineSoft
        }
    }

    private var iconColor: Color {
        style == .primary ? Color.white.opacity(0.94) : EntuleTheme.inkDim
    }

    private var textColor: Color {
        style == .primary ? .white : EntuleTheme.ink
    }

    private var textSize: CGFloat {
        if size >= 320 { return 42 }
        if size >= 250 { return 32 }
        return 24
    }

    private var iconSize: CGFloat {
        if size >= 320 { return 42 }
        if size >= 250 { return 34 }
        return 26
    }

    @ViewBuilder
    private var iconView: some View {
        switch icon {
        case .system(let symbol):
            Image(systemName: symbol)
                .font(.system(size: iconSize, weight: .medium))
                .foregroundStyle(iconColor)
        case .assetPNG(let name):
            if let url = Bundle.main.url(forResource: name, withExtension: "png"),
               let image = NSImage(contentsOf: url) {
                Image(nsImage: image)
                    .resizable()
                    .renderingMode(.template)
                    .interpolation(.high)
                    .foregroundStyle(iconColor)
                    .frame(width: iconSize, height: iconSize)
            } else {
                Image(systemName: "circle.dashed")
                    .font(.system(size: iconSize, weight: .medium))
                    .foregroundStyle(iconColor)
            }
        }
    }

    private var shadowColor: Color {
        switch style {
        case .primary:
            return EntuleTheme.orange.opacity(disabled ? 0.08 : (isHovered ? 0.22 : 0.16))
        case .secondary:
            return Color.black.opacity(isHovered ? 0.08 : 0.05)
        }
    }
}
