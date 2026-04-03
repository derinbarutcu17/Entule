import SwiftUI

struct EntuleDashboardView: View {
    @ObservedObject var appShellViewModel: AppShellViewModel
    @ObservedObject var workspaceViewModel: WorkspaceViewModel

    @State private var selectedPreviewItemIDs: Set<UUID> = []

    var body: some View {
        GeometryReader { proxy in
            let contentSize = CGSize(
                width: max(proxy.size.width - (AppWindowMetrics.outerPadding * 2), 0),
                height: max(proxy.size.height - AppWindowMetrics.titlebarTopInset - AppWindowMetrics.outerPadding, 0)
            )

            VStack(alignment: .leading, spacing: AppWindowMetrics.shellHeaderBottomSpacing) {
                shellHeader(for: contentSize)

                ZStack(alignment: .bottomTrailing) {
                    shellContent(for: contentSize)
                    floatingDock
                        .padding(.trailing, AppWindowMetrics.spacingXS)
                        .padding(.bottom, AppWindowMetrics.spacingXS)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .padding(.top, AppWindowMetrics.titlebarTopInset)
            .padding(.horizontal, AppWindowMetrics.outerPadding)
            .padding(.bottom, AppWindowMetrics.outerPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .entuleWindowBackground()
        .onAppear(perform: syncPreviewSelection)
        .onChange(of: workspaceViewModel.lastSnapshot?.id) { _ in
            syncPreviewSelection()
        }
    }

    private func shellHeader(for contentSize: CGSize) -> some View {
        Text("Entule")
            .font(EntuleTypography.font(headerFontSize(for: contentSize.width), weight: .semibold))
            .foregroundStyle(EntuleTheme.ink)
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
        let frames = HomeLayout.make(in: size)
        let utilityButtonHeight = frames.utilityFrame.height / 2 - frames.utilitySpacing / 2

        return ZStack(alignment: .topLeading) {
            homeOrb(
                title: "Save\nSession",
                frame: frames.saveFrame,
                action: { appShellViewModel.showSaveSession() },
                disabled: workspaceViewModel.isBusy,
                accessory: .curvedText(lastSaveLabel)
            )

            homeOrb(
                title: "Resume\nSession",
                frame: frames.resumeFrame,
                action: {
                    Task { _ = await workspaceViewModel.resumeLastSnapshot(selectedItemIDs: selectedPreviewItemIDs) }
                },
                disabled: !canResumeSelection,
                accessory: .none
            )

            previewChecklistCard(frame: frames.previewFrame)

            homeOrb(
                title: selectedItemsLabel,
                frame: frames.inspectFrame,
                action: { appShellViewModel.inspectCheckpoint() },
                disabled: workspaceViewModel.lastSnapshot == nil,
                accessory: .none
            )

            VStack(spacing: frames.utilitySpacing) {
                HomeUtilityButton(
                    width: frames.utilityFrame.width,
                    height: utilityButtonHeight,
                    action: { appShellViewModel.openSettings() }
                ) {
                    Image(systemName: "gearshape")
                        .font(.system(size: frames.tier == .compact ? 24 : 28, weight: .regular))
                }

                HomeUtilityButton(
                    width: frames.utilityFrame.width,
                    height: utilityButtonHeight,
                    action: { appShellViewModel.openPresets() }
                ) {
                    VStack(spacing: frames.tier == .compact ? 3 : 4) {
                        Text("Presets")
                            .font(EntuleTypography.font(frames.tier == .compact ? 14 : 17, weight: .medium))
                        Image(systemName: "plus.square.on.square")
                            .font(.system(size: frames.tier == .compact ? 15 : 18, weight: .regular))
                    }
                }
            }
            .frame(width: frames.utilityFrame.width, height: frames.utilityFrame.height, alignment: .top)
            .offset(x: frames.utilityFrame.minX, y: frames.utilityFrame.minY)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var secondaryScene: some View {
        ScrollView {
            activeSectionPage
                .frame(maxWidth: AppWindowMetrics.shellContentMaxWidth, alignment: .topLeading)
                .padding(.trailing, AppWindowMetrics.shellDockReservedWidth)
                .frame(maxWidth: .infinity, alignment: .topLeading)
        }
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
                        workspaceViewModel: workspaceViewModel,
                        onClose: { appShellViewModel.showHome() }
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

    private func previewChecklistCard(frame: CGRect) -> some View {
        let tier = HomeLayout.make(in: CGSize(width: frame.maxX + 1, height: frame.maxY + 1)).tier
        let items = previewItems

        return HomeBlobCard(interactiveSurface: false) {
            VStack(alignment: .leading, spacing: tier == .compact ? 5 : 6) {
                if items.isEmpty {
                    Text("No saved\nitems yet")
                        .font(EntuleTypography.font(tier == .compact ? 14 : 18, weight: .medium))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                } else {
                    ForEach(items) { item in
                        Button {
                            togglePreviewItem(item.id)
                        } label: {
                            HStack(spacing: tier == .compact ? 6 : 8) {
                                Image(systemName: selectedPreviewItemIDs.contains(item.id) ? "checkmark.square.fill" : "square")
                                    .font(.system(size: tier == .compact ? 10 : 12, weight: .semibold))
                                Text(item.displayName)
                                    .font(EntuleTypography.font(tier == .compact ? 12 : 15))
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: tier == .compact ? 18 : AppWindowMetrics.homePreviewRowHeight, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                    }

                    if hiddenItemCount > 0 {
                        Button("Inspect all") { appShellViewModel.inspectCheckpoint() }
                            .font(EntuleTypography.font(tier == .compact ? 10 : 12, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.9))
                            .buttonStyle(.plain)
                            .padding(.top, tier == .compact ? 2 : 4)
                    }
                }
            }
            .padding(.horizontal, tier == .compact ? 12 : AppWindowMetrics.panelPadding * 0.9)
            .padding(.vertical, tier == .compact ? 12 : AppWindowMetrics.panelPadding * 0.85)
            .frame(width: frame.width, height: frame.height, alignment: .topLeading)
        }
        .offset(x: frame.minX, y: frame.minY)
    }

    private func homeOrb(
        title: String,
        frame: CGRect,
        action: @escaping () -> Void,
        disabled: Bool,
        accessory: HomeOrbAccessory
    ) -> some View {
        HomeOrbButton(
            title: title,
            size: frame.width,
            fontSize: orbFontSize(for: frame.width),
            disabled: disabled,
            accessory: accessory,
            action: action
        )
        .offset(x: frame.minX, y: frame.minY)
    }

    private var floatingDock: some View {
        VStack(alignment: .trailing, spacing: AppWindowMetrics.floatingDockSpacing) {
            ForEach(AppSection.allCases.filter { $0 != .home }) { section in
                FloatingSectionButton(
                    section: section,
                    isActive: appShellViewModel.activeSection == section,
                    action: { appShellViewModel.navigate(to: section) }
                )
            }

            FloatingSectionButton(section: .home, isActive: false) {
                appShellViewModel.showHome()
            }
        }
    }

    private var previewItems: [SessionItem] {
        guard let snapshot = workspaceViewModel.lastSnapshot else { return [] }
        return Array(snapshot.items.prefix(5))
    }

    private var hiddenItemCount: Int {
        guard let snapshot = workspaceViewModel.lastSnapshot else { return 0 }
        return max(snapshot.items.count - previewItems.count, 0)
    }

    private var selectedItemsLabel: String {
        let selectedCount = selectedPreviewCount
        return selectedCount == 1 ? "1 Item" : "\(selectedCount) Items"
    }

    private var selectedPreviewCount: Int {
        guard let snapshot = workspaceViewModel.lastSnapshot else { return 0 }
        return snapshot.items.filter { selectedPreviewItemIDs.contains($0.id) }.count
    }

    private var canResumeSelection: Bool {
        workspaceViewModel.canResumeLastSession && selectedPreviewCount > 0
    }

    private var lastSaveLabel: String {
        guard let snapshot = workspaceViewModel.lastSnapshot else {
            return "save a checkpoint"
        }
        return "last save: \(snapshot.createdAt.formatted(date: .abbreviated, time: .shortened))"
    }

    private func togglePreviewItem(_ id: UUID) {
        if selectedPreviewItemIDs.contains(id) {
            selectedPreviewItemIDs.remove(id)
        } else {
            selectedPreviewItemIDs.insert(id)
        }
    }

    private func syncPreviewSelection() {
        guard let snapshot = workspaceViewModel.lastSnapshot else {
            selectedPreviewItemIDs = []
            return
        }
        selectedPreviewItemIDs = Set(snapshot.items.map(\.id))
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

    private func headerFontSize(for width: CGFloat) -> CGFloat {
        if width < 960 { return 42 }
        if width < 1180 { return 52 }
        return 60
    }

    private func orbFontSize(for size: CGFloat) -> CGFloat {
        if size >= 380 { return 68 }
        if size >= 250 { return 40 }
        return 18
    }
}

private enum HomeOrbAccessory {
    case none
    case curvedText(String)
}

private struct HomeOrbButton: View {
    let title: String
    let size: CGFloat
    let fontSize: CGFloat
    let disabled: Bool
    let accessory: HomeOrbAccessory
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(EntuleTheme.primaryButtonGradient)
                .overlay(
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.16), Color.clear],
                                center: .topLeading,
                                startRadius: 8,
                                endRadius: size * 0.75
                            )
                        )
                        .blendMode(.screen)
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(isHovered ? 0.28 : 0.14), lineWidth: size * 0.01)
                )
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.08), lineWidth: size * 0.02)
                        .blur(radius: size * 0.045)
                        .offset(y: size * 0.025)
                        .mask(Circle().fill(LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)))
                )
                .overlay {
                    Text(title)
                        .font(EntuleTypography.font(fontSize, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.white)
                        .padding(size * 0.17)
                        .minimumScaleFactor(0.7)
                }
                .overlay(alignment: .bottom) {
                    if case let .curvedText(detail) = accessory {
                        ArcText(text: detail, radius: size * 0.395, fontSize: max(fontSize * 0.33, 12))
                            .frame(width: size, height: size)
                            .offset(y: size * 0.03)
                    }
                }
                .frame(width: size, height: size)
                .scaleEffect(isHovered && !disabled ? 1.03 : 1)
                .opacity(disabled ? 0.42 : 1)
                .shadow(color: EntuleTheme.orange.opacity(disabled ? 0.08 : (isHovered ? 0.26 : 0.18)), radius: isHovered ? 22 : 14, y: isHovered ? 12 : 8)
                .animation(.easeOut(duration: 0.18), value: isHovered)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

private struct HomeBlobCard<Content: View>: View {
    let interactiveSurface: Bool
    let content: Content

    @State private var isHovered = false

    init(interactiveSurface: Bool = true, @ViewBuilder content: () -> Content) {
        self.interactiveSurface = interactiveSurface
        self.content = content()
    }

    var body: some View {
        content
            .background(EntuleTheme.primaryButtonGradient)
            .clipShape(RoundedRectangle(cornerRadius: AppWindowMetrics.panelCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppWindowMetrics.panelCornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(isHovered ? 0.25 : 0.12), lineWidth: 1)
            )
            .shadow(color: EntuleTheme.orange.opacity(isHovered ? 0.24 : 0.18), radius: isHovered ? 18 : 12, y: isHovered ? 10 : 8)
            .scaleEffect(interactiveSurface && isHovered ? 1.02 : 1)
            .animation(.easeOut(duration: 0.18), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

private struct ArcText: View {
    let text: String
    let radius: CGFloat
    let fontSize: CGFloat

    var body: some View {
        let characters = Array(text)
        let totalSpan = min(max(Double(characters.count - 1) * 4.2, 26), 62)
        let startAngle = 90 + (totalSpan / 2)
        let step = characters.count > 1 ? totalSpan / Double(characters.count - 1) : 0

        return ZStack {
            ForEach(Array(characters.enumerated()), id: \.offset) { index, character in
                let angle = startAngle - (Double(index) * step)
                let radians = angle * .pi / 180
                Text(String(character))
                    .font(EntuleTypography.font(fontSize, weight: .medium))
                    .foregroundStyle(Color.white)
                    .position(
                        x: radius + cos(radians) * radius,
                        y: radius + sin(radians) * radius
                    )
                    .rotationEffect(.degrees(angle - 90))
            }
        }
        .frame(width: radius * 2, height: radius * 2)
    }
}
