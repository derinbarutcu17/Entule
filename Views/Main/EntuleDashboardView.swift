import SwiftUI

struct EntuleDashboardView: View {
    @ObservedObject var menuBarViewModel: MenuBarViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("EARLY ACCESS")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(2.6)
                        .foregroundStyle(EntuleTheme.amber)
                    Text("Return to work instantly.")
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .foregroundStyle(EntuleTheme.moon)
                    Text("Entule saves lightweight checkpoints across apps, folders, files, and URLs so you can get back into flow quickly.")
                        .font(.system(size: 15))
                        .foregroundStyle(EntuleTheme.moonDim)
                    Text(menuBarViewModel.statusLine)
                        .font(.footnote)
                        .foregroundStyle(EntuleTheme.moonDim)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Actions")
                        .font(.headline)
                        .foregroundStyle(EntuleTheme.moon)

                    HStack(spacing: 12) {
                        Button("Save Current Session") {
                            menuBarViewModel.beginSaveSession()
                            AppWindowController.shared.showSaveSession(menuBarViewModel: menuBarViewModel)
                        }
                        .buttonStyle(EntulePrimaryButtonStyle())
                        .disabled(menuBarViewModel.isBusy)

                        Button("Resume Last Session") {
                            guard menuBarViewModel.canResumeLastSession else { return }
                            menuBarViewModel.beginResumeSession()
                            AppWindowController.shared.showResumeSession(menuBarViewModel: menuBarViewModel)
                        }
                        .buttonStyle(EntuleSecondaryButtonStyle())
                        .disabled(!menuBarViewModel.canResumeLastSession)

                        Button("Presets…") {
                            menuBarViewModel.openPresets()
                            AppWindowController.shared.showPresets(menuBarViewModel: menuBarViewModel)
                        }
                        .buttonStyle(EntuleSecondaryButtonStyle())
                    }

                    Text("Use the menu bar for quick access, or keep this window open while saving and resuming sessions.")
                        .font(.caption)
                        .foregroundStyle(EntuleTheme.moonDim)
                }
                .entulePanel()

                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Last Checkpoint")
                            .font(.headline)
                            .foregroundStyle(EntuleTheme.moon)

                        if let snapshot = menuBarViewModel.lastSnapshot {
                            checkpointStatRow(label: "Created", value: snapshot.createdAt.formatted(date: .abbreviated, time: .shortened))
                            checkpointStatRow(label: "Items", value: "\(snapshot.items.count)")

                            if !snapshot.note.isEmpty {
                                Text(snapshot.note)
                                    .font(.callout)
                                    .foregroundStyle(EntuleTheme.moon)
                                    .padding(.top, 4)
                            }
                        } else {
                            Text("No checkpoint saved yet.")
                                .foregroundStyle(EntuleTheme.moonDim)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .entulePanel()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Presets")
                            .font(.headline)
                            .foregroundStyle(EntuleTheme.moon)

                        if menuBarViewModel.presets.isEmpty {
                            Text("No presets yet. Open Presets to create one.")
                                .foregroundStyle(EntuleTheme.moonDim)
                        } else {
                            ForEach(menuBarViewModel.presets.prefix(4)) { preset in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(preset.name)
                                            .foregroundStyle(EntuleTheme.moon)
                                        Text("\(preset.items.count) items")
                                            .font(.caption)
                                            .foregroundStyle(EntuleTheme.moonDim)
                                    }
                                    Spacer()
                                    Button("Launch") {
                                        Task { await menuBarViewModel.launchPreset(preset) }
                                    }
                                    .buttonStyle(EntuleSecondaryButtonStyle())
                                    .disabled(menuBarViewModel.isBusy)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .entulePanel()
                }
            }
            .padding(20)
        }
        .frame(minWidth: 760, minHeight: 560)
        .entuleWindowBackground()
        .background(
            WindowAccessor { window in
                WindowCoordinator.activate(window: window)
            }
        )
    }

    private func checkpointStatRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(EntuleTheme.moonDim)
            Spacer()
            Text(value)
                .foregroundStyle(EntuleTheme.moon)
        }
        .font(.system(size: 13))
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.04))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(EntuleTheme.lineSoft, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
