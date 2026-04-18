import SwiftUI
import AppKit

struct SaveSessionSheet: View {
    @StateObject var viewModel: SaveSessionViewModel
    @ObservedObject var workspaceViewModel: WorkspaceViewModel
    var onClose: (() -> Void)? = nil

    @State private var manualURL = ""
    @State private var confirmSaveWithZeroItems = false
    @State private var isSaving = false
    @State private var manualAddExpanded = false
    @FocusState private var manualURLFocused: Bool

    private var groupedItems: [SessionItemKind: [SessionItem]] {
        Dictionary(grouping: viewModel.items, by: { $0.kind })
    }

    private var orderedKinds: [SessionItemKind] {
        [.app, .url, .file, .folder]
    }

    var body: some View {
        AppPaneContainer {
            sessionItemsPanel
        }
        .task {
            await detectSession()
        }
        .onChange(of: manualURL) { _ in viewModel.clearInputError() }
        .alert("Save empty snapshot?", isPresented: $confirmSaveWithZeroItems) {
            Button("Cancel", role: .cancel) {}
            Button("Save") { persistAndClose() }
        } message: {
            Text("No items are selected. Entule will save a checkpoint with only the session title.")
        }
    }

    private var sessionItemsPanel: some View {
        VStack(alignment: .leading, spacing: AppWindowMetrics.spacingXS) {
            Text("\(viewModel.selectedCount) selected of \(viewModel.detectedCount) items")
                .font(EntuleTypography.font(13, weight: .medium))
                .foregroundStyle(EntuleTheme.inkDim)

            sessionItemsHeader

            if viewModel.items.isEmpty && !viewModel.isDetecting {
                VStack(alignment: .leading, spacing: AppWindowMetrics.spacingXS) {
                    Text("No Session Items Found")
                        .font(EntuleTypography.font(18, weight: .semibold))
                        .foregroundStyle(EntuleTheme.ink)
                    Text("Use Add manually to include apps, files, folders, or links in this checkpoint.")
                        .font(EntuleTypography.font(13))
                        .foregroundStyle(EntuleTheme.inkDim)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            } else {
                sessionItemsScrollView

                if !viewModel.hasDetectedLinks {
                    Text("Browser links appear here when Safari, Chrome, or Dia automation access is available in macOS settings.")
                        .font(EntuleTypography.font(12))
                        .foregroundStyle(EntuleTheme.inkDim)
                        .fixedSize(horizontal: false, vertical: true)

                    let browserDetectorStatusLines = viewModel.detectorStatusLines.filter { line in
                        let lower = line.lowercased()
                        return lower.contains("dia:") || lower.contains("chrome:") || lower.contains("safari:")
                    }

                    if !browserDetectorStatusLines.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(browserDetectorStatusLines, id: \.self) { line in
                                Text(line)
                                    .font(EntuleTypography.font(12))
                                    .foregroundStyle(EntuleTheme.inkSoft)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .entulePanel()
    }

    private var sessionItemsScrollView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
                ForEach(orderedKinds, id: \.self) { kind in
                    if let sectionItems = groupedItems[kind], !sectionItems.isEmpty {
                        sectionBlock(kind: kind, items: sectionItems)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(.vertical, 2)
        }
        .scrollIndicators(.visible)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .layoutPriority(1)
    }

    private var sessionItemsHeader: some View {
        VStack(alignment: .leading, spacing: AppWindowMetrics.spacingXS) {
            Text("Session Items")
                .font(EntuleTypography.font(20, weight: .semibold))
                .foregroundStyle(EntuleTheme.ink)

            Text("Choose what should be reopened the next time you resume this session.")
                .font(EntuleTypography.font(13))
                .foregroundStyle(EntuleTheme.inkDim)
                .fixedSize(horizontal: false, vertical: true)

            ViewThatFits(in: .horizontal) {
                TextField("Session name (optional)", text: $viewModel.note)
                    .entuleInputField()
                    .padding(.trailing, 128)
                    .overlay(alignment: .trailing) {
                        saveCheckpointOrb
                    }

                VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
                    TextField("Session name (optional)", text: $viewModel.note)
                        .entuleInputField()
                    HStack {
                        Spacer(minLength: 0)
                        saveCheckpointOrb
                    }
                }
            }

            Text("Leave this empty and Entule will use the current date and time.")
                .font(EntuleTypography.font(12))
                .foregroundStyle(EntuleTheme.inkDim)
                .fixedSize(horizontal: false, vertical: true)

            responsiveActionButtons {
                HStack(spacing: AppWindowMetrics.spacingS) {
                    Button("Select All") { viewModel.selectAll() }
                        .buttonStyle(EntuleSecondaryButtonStyle())
                    Button("Deselect All") { viewModel.deselectAll() }
                        .buttonStyle(EntuleSecondaryButtonStyle())
                    Button("Refresh Items") {
                        Task { await detectSession() }
                    }
                    .buttonStyle(EntuleSecondaryButtonStyle())
                    addManuallyButton
                    if viewModel.isDetecting {
                        ProgressView()
                            .padding(.leading, 4)
                    }
                }
            } vertical: {
                VStack(alignment: .leading, spacing: AppWindowMetrics.spacingXS) {
                    Button("Select All") { viewModel.selectAll() }
                        .buttonStyle(EntuleSecondaryButtonStyle())
                    Button("Deselect All") { viewModel.deselectAll() }
                        .buttonStyle(EntuleSecondaryButtonStyle())
                    Button("Refresh Items") {
                        Task { await detectSession() }
                    }
                    .buttonStyle(EntuleSecondaryButtonStyle())
                    addManuallyButton
                    if viewModel.isDetecting {
                        ProgressView()
                    }
                }
            }

            if let inputError = viewModel.inputErrorMessage {
                Text(inputError)
                    .font(EntuleTypography.font(12, weight: .medium))
                    .foregroundStyle(EntuleTheme.danger)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .disabled(viewModel.isDetecting || isSaving)
    }

    private var saveCheckpointOrb: some View {
        Button {
            if viewModel.shouldConfirmEmptySelection() {
                confirmSaveWithZeroItems = true
            } else {
                persistAndClose()
            }
        } label: {
            Circle()
                .fill(EntuleTheme.primaryButtonGradient)
                .frame(width: 112, height: 112)
                .overlay {
                    VStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 22, weight: .semibold))
                        Text(viewModel.isDetecting ? "Wait" : (isSaving ? "Saving" : "Save"))
                            .font(EntuleTypography.font(15, weight: .bold))
                    }
                    .foregroundStyle(Color.white)
                }
                .shadow(color: EntuleTheme.orange.opacity(0.18), radius: 16, y: 10)
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isDetecting || isSaving)
        .accessibilityLabel("Save Checkpoint")
    }

    private func manualAddButton(title: String, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .buttonStyle(EntuleSecondaryButtonStyle())
    }

    private func responsiveActionButtons<Horizontal: View, Vertical: View>(
        @ViewBuilder horizontal: () -> Horizontal,
        @ViewBuilder vertical: () -> Vertical
    ) -> some View {
        ViewThatFits(in: .horizontal) {
            horizontal()
            vertical()
        }
    }

    private var addManuallyButton: some View {
        Button("Add manually") {
            manualAddExpanded.toggle()
        }
        .buttonStyle(EntulePrimaryButtonStyle())
        .popover(isPresented: $manualAddExpanded, arrowEdge: .bottom) {
            manualAddMenu
        }
    }

    private var manualAddMenu: some View {
        VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
            manualAddButton(title: "Add App") {
                collapseManualAdd()
                viewModel.addManualAppsFromPicker()
            }
            manualAddButton(title: "Add File") {
                collapseManualAdd()
                viewModel.addManualFilesFromPicker()
            }
            manualAddButton(title: "Add Folder") {
                collapseManualAdd()
                viewModel.addManualFoldersFromPicker()
            }

            VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
                TextField("Add link", text: $manualURL)
                    .entuleInputField()
                    .frame(width: 220)
                    .focused($manualURLFocused)

                manualAddButton(title: "Add Link") {
                    if viewModel.addManualURL(raw: manualURL) {
                        manualURL = ""
                        manualURLFocused = false
                        collapseManualAdd()
                    }
                }
            }
        }
        .padding(14)
        .frame(minWidth: 250)
        .background(Color.white.opacity(0.96))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(EntuleTheme.lineWarm, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 18, y: 12)
    }

    private func sectionBlock(kind: SessionItemKind, items: [SessionItem]) -> some View {
        VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
            HStack(spacing: AppWindowMetrics.spacingS) {
                Text({
                    switch kind {
                    case .app: "Apps"
                    case .file: "Files"
                    case .folder: "Folders"
                    case .url: "Links"
                    }
                }())
                    .font(EntuleTypography.font(18, weight: .semibold))
                    .foregroundStyle(EntuleTheme.ink)

                Text("\(items.count)")
                    .font(EntuleTypography.font(13, weight: .semibold))
                    .foregroundStyle(EntuleTheme.inkDim)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.85))
                    .clipShape(Capsule())

                if kind == .app {
                    Button("Deselect Apps") {
                        viewModel.deselectAll(of: .app)
                    }
                    .buttonStyle(EntuleSecondaryButtonStyle())
                } else if kind == .url {
                    Button("Deselect Links") {
                        viewModel.deselectAll(of: .url)
                    }
                    .buttonStyle(EntuleSecondaryButtonStyle())
                }

                Spacer(minLength: 0)
            }

            if kind == .app {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: AppWindowMetrics.spacingS, alignment: .top)], alignment: .leading, spacing: AppWindowMetrics.spacingS) {
                    ForEach(items) { item in
                        appCard(for: item)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: AppWindowMetrics.spacingXS) {
                    ForEach(items) { item in
                        linkLikeRow(for: item)
                    }
                }
            }
        }
        .padding(AppWindowMetrics.spacingS)
        .background(Color.white.opacity(0.52))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(EntuleTheme.lineSoft, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func appCard(for item: SessionItem) -> some View {
        let selected = item.isSelected
        return ZStack(alignment: .topLeading) {
            VStack(spacing: 10) {
                appIcon(for: item)
                    .frame(width: 54, height: 54)
                    .padding(.top, 8)

                Text(item.displayName)
                    .font(EntuleTypography.font(14, weight: .semibold))
                    .foregroundStyle(EntuleTheme.ink)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .center)

                Button("Remove") { viewModel.removeItem(item) }
                    .buttonStyle(EntuleSecondaryButtonStyle())
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 152, alignment: .top)
            .background(selected ? EntuleTheme.orange.opacity(0.14) : Color.white.opacity(0.92))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(selected ? EntuleTheme.orange : EntuleTheme.lineSoft, lineWidth: selected ? 1.5 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .onTapGesture {
                toggleSelection(for: item.id)
            }

            if selected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(EntuleTheme.orange)
                    .padding(8)
            }
        }
    }

    private func linkLikeRow(for item: SessionItem) -> some View {
        let selected = item.isSelected
        return HStack(alignment: .center, spacing: AppWindowMetrics.spacingS) {
            appIcon(for: item)
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.displayName)
                    .font(EntuleTypography.font(15, weight: .semibold))
                    .foregroundStyle(EntuleTheme.ink)
                    .lineLimit(1)
                    .truncationMode(.tail)

                if item.kind == .url {
                    Text(item.value)
                        .font(EntuleTypography.font(13))
                        .foregroundStyle(EntuleTheme.inkDim)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }

            Spacer(minLength: 0)

            Button("Remove") { viewModel.removeItem(item) }
                .buttonStyle(EntuleSecondaryButtonStyle())
        }
        .padding(10)
        .background(selected ? EntuleTheme.orange.opacity(0.12) : Color.white.opacity(0.88))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(selected ? EntuleTheme.orange : EntuleTheme.lineSoft, lineWidth: selected ? 1.5 : 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .onTapGesture {
            toggleSelection(for: item.id)
        }
    }

    private func appIcon(for item: SessionItem) -> some View {
        Group {
            if let image = resolvedIcon(for: item) {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.high)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(EntuleTheme.orangeWash)
                    .overlay {
                        Image(systemName: fallbackSymbol(for: item.kind))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(EntuleTheme.orange)
                    }
            }
        }
    }

    private func persistAndClose() {
        guard !isSaving else { return }
        isSaving = true
        workspaceViewModel.saveSnapshot(viewModel.toSnapshot())
        onClose?()
    }

    private func toggleSelection(for id: UUID) {
        guard let idx = viewModel.items.firstIndex(where: { $0.id == id }) else { return }
        viewModel.items[idx].isSelected.toggle()
    }

    private func collapseManualAdd() {
        guard manualAddExpanded else { return }
        withAnimation(.easeOut(duration: 0.18)) {
            manualAddExpanded = false
        }
        manualURLFocused = false
    }

    private func detectSession() async {
        viewModel.isDetecting = true
        let result = await workspaceViewModel.detectCurrentSession()
        viewModel.loadDetectionResult(result)
        viewModel.isDetecting = false
    }

    private func resolvedIcon(for item: SessionItem) -> NSImage? {
        let cacheKey: String
        switch item.kind {
        case .app:
            guard let path = item.appPath, !path.isEmpty else { return nil }
            cacheKey = "app::\(path)"
        case .file, .folder:
            cacheKey = "\(item.kind.rawValue)::\(item.value)"
        case .url:
            return nil
        }

        if let cached = SaveSessionIconCache.shared.object(forKey: cacheKey as NSString) {
            return cached
        }

        let image = NSWorkspace.shared.icon(forFile: item.kind == .app ? (item.appPath ?? item.value) : item.value)
        SaveSessionIconCache.shared.setObject(image, forKey: cacheKey as NSString)
        return image
    }

    private func fallbackSymbol(for kind: SessionItemKind) -> String {
        switch kind {
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

private enum SaveSessionIconCache {
    static let shared = NSCache<NSString, NSImage>()
}
