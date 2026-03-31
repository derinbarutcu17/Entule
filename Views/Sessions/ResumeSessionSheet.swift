import SwiftUI

struct ResumeSessionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: ResumeSessionViewModel
    @ObservedObject var menuBarViewModel: MenuBarViewModel

    @State private var running = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Resume Last Session")
                .font(.title3.bold())

            Text("Created: \(viewModel.snapshot.createdAt.formatted())")
                .foregroundStyle(.secondary)

            if !viewModel.snapshot.note.isEmpty {
                GroupBox("Saved Note") {
                    Text(viewModel.snapshot.note)
                }
            }

            Text("Items to reopen: \(viewModel.snapshot.items.count)")

            List(viewModel.snapshot.items) { item in
                HStack {
                    Text(item.kind.rawValue.uppercased())
                        .font(.caption)
                        .frame(width: 60, alignment: .leading)
                        .foregroundStyle(.secondary)
                    Text(item.displayName)
                    Spacer()
                    Text(item.value)
                        .foregroundStyle(.secondary)
                }
            }

            if let report = viewModel.lastReport {
                Text("Resumed \(report.successes.count), Failed \(report.failures.count)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Button("Cancel") { dismiss() }
                Spacer()
                Button(running ? "Resuming…" : "Resume") {
                    Task {
                        running = true
                        viewModel.lastReport = await menuBarViewModel.resumeLastSnapshot()
                        running = false
                    }
                }
                .disabled(running)
            }
        }
        .padding()
        .onAppear {
            if viewModel.needsConfirmation {
                viewModel.showConfirmation = true
            }
        }
        .alert("Resume \(viewModel.snapshot.items.count) items?", isPresented: $viewModel.showConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Resume") {
                Task {
                    running = true
                    viewModel.lastReport = await menuBarViewModel.resumeLastSnapshot()
                    running = false
                }
            }
        }
    }
}
