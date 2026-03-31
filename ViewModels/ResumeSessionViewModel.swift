import Foundation

@MainActor
final class ResumeSessionViewModel: ObservableObject {
    @Published var showConfirmation = false
    @Published var lastReport: LaunchReport?

    let snapshot: SessionSnapshot

    init(snapshot: SessionSnapshot) {
        self.snapshot = snapshot
    }

    var needsConfirmation: Bool {
        snapshot.items.count >= 12
    }
}
