import Foundation

@MainActor
final class ResumeSessionViewModel: ObservableObject {
    @Published var lastReport: LaunchReport?

    let snapshot: SessionSnapshot

    init(snapshot: SessionSnapshot) {
        self.snapshot = snapshot
    }
}
