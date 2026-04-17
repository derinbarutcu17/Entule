import SwiftUI

extension Notification.Name {
    static let entuleResetTutorial = Notification.Name("entule.resetTutorial")
}

enum TutorialTarget: Hashable {
    case save
    case inspect
    case resume
    case presets
    case settings

    var spotlightYOffset: CGFloat {
        switch self {
        case .save, .inspect, .presets, .settings:
            return 10
        case .resume:
            return 8
        }
    }

    var spotlightPadding: CGFloat {
        switch self {
        case .save, .inspect, .presets, .settings:
            return 8
        case .resume:
            return 10
        }
    }
}

enum TutorialStep: Int, CaseIterable {
    case welcome
    case save
    case inspect
    case resume
    case presets
    case settingsDone

    var title: String {
        switch self {
        case .welcome:
            return "Welcome"
        case .save:
            return "Save Sessions"
        case .inspect:
            return "Inspect Before Opening"
        case .resume:
            return "Resume Instantly"
        case .presets:
            return "Presets"
        case .settingsDone:
            return "Settings & Done"
        }
    }

    var message: String {
        switch self {
        case .welcome:
            return "Welcome to Entule. We’ll walk through the navigation bar and the main pages for saving, inspecting, resuming, presets, and settings."
        case .save:
            return "Open Save in the navigation bar to capture your current apps, files, and browser tabs into a single checkpoint."
        case .inspect:
            return "Open Inspect to review what’s inside a session before you launch it."
        case .resume:
            return "Use the Resume button on the Inspect page to launch a saved session instantly."
        case .presets:
            return "Open Presets to create reusable templates for your daily routines."
        case .settingsDone:
            return "Open Settings to manage permissions and reset the tutorial whenever you want to replay it."
        }
    }

    var target: TutorialTarget? {
        switch self {
        case .welcome:
            return nil
        case .save:
            return .save
        case .inspect:
            return .inspect
        case .resume:
            return .resume
        case .presets:
            return .presets
        case .settingsDone:
            return .settings
        }
    }

    var preferredSection: AppSection? {
        switch self {
        case .welcome:
            return .home
        case .save:
            return .saveSession
        case .inspect:
            return .inspectCheckpoint
        case .resume:
            return .inspectCheckpoint
        case .presets:
            return .presets
        case .settingsDone:
            return .settings
        }
    }
}

@MainActor
final class TutorialManager: ObservableObject {
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial = false

    @Published var isActive = false
    @Published var currentStep: TutorialStep = .welcome

    func startTutorial(force: Bool = false) {
        if !force && hasSeenTutorial {
            return
        }
        currentStep = .welcome
        isActive = true
    }

    func startIfNeeded() {
        guard !hasSeenTutorial else { return }
        startTutorial(force: true)
    }

    func nextStep() {
        guard let index = TutorialStep.allCases.firstIndex(of: currentStep) else {
            completeTutorial()
            return
        }

        let nextIndex = TutorialStep.allCases.index(after: index)
        if nextIndex == TutorialStep.allCases.endIndex {
            completeTutorial()
        } else {
            currentStep = TutorialStep.allCases[nextIndex]
        }
    }

    func skipTutorial() {
        completeTutorial()
    }

    static func resetPersistentFlag() {
        UserDefaults.standard.set(false, forKey: "hasSeenTutorial")
        NotificationCenter.default.post(name: .entuleResetTutorial, object: nil)
    }

    private func completeTutorial() {
        hasSeenTutorial = true
        isActive = false
    }
}
