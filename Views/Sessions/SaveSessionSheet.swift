import SwiftUI

struct SaveSessionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: SaveSessionViewModel
    @ObservedObject var menuBarViewModel: MenuBarViewModel

    @State private var manualURL = ""
    @State private var manualPath = ""

    private var groupedItems: [SessionItemKind: [SessionItem]] {
        Dictionary(grouping: viewModel.items, by: { $0.kind })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Save Current Session")
                .font(.title3.bold())

            HStack {
                Button("Select All") { viewModel.selectAll() }
                Button("Deselect All") { viewModel.deselectAll() }
                Spacer()
                if viewModel.isDetecting { ProgressView() }
            }

            if !viewModel.detectionErrors.isEmpty {
                Text(viewModel.detectionErrors.joined(separator: "\n"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            List {
                ForEach(SessionItemKind.allCases, id: \.self) { kind in
                    if let indexList = groupedItems[kind], !indexList.isEmpty {
                        Section(kind.rawValue.uppercased()) {
                            ForEach(indexList) { sectionItem in
                                if let binding = binding(for: sectionItem.id) {
                                    SessionItemRow(item: binding) {
                                        viewModel.removeItem(sectionItem)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            GroupBox("Manual Add") {
                HStack {
                    TextField("URL", text: $manualURL)
                    Button("Add URL") {
                        viewModel.addManualURL(raw: manualURL)
                        manualURL = ""
                    }
                }

                HStack {
                    TextField("Path", text: $manualPath)
                    Button("Add File") {
                        viewModel.addManualPath(path: manualPath, isFolder: false)
                        manualPath = ""
                    }
                    Button("Add Folder") {
                        viewModel.addManualPath(path: manualPath, isFolder: true)
                        manualPath = ""
                    }
                }
            }

            TextField("Note", text: $viewModel.note)
            TextField("Shortcut Name (optional)", text: $viewModel.shortcutName)

            HStack {
                Button("Cancel") { dismiss() }
                Spacer()
                Button("Save Snapshot") {
                    menuBarViewModel.saveSnapshot(viewModel.toSnapshot())
                    dismiss()
                }
            }
        }
        .padding()
        .task {
            viewModel.isDetecting = true
            let result = await menuBarViewModel.detectCurrentSession()
            viewModel.loadDetectionResult(result)
            viewModel.isDetecting = false
        }
    }

    private func binding(for id: UUID) -> Binding<SessionItem>? {
        guard let idx = viewModel.items.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        return $viewModel.items[idx]
    }
}
