import Foundation

enum AppWindowMetrics {
    static let defaultWindowWidth: CGFloat = 1080
    static let defaultWindowHeight: CGFloat = 720
    static let minimumWindowWidth: CGFloat = 920
    static let minimumWindowHeight: CGFloat = 640

    static let outerPadding: CGFloat = 20
    static let titlebarTopInset: CGFloat = 26

    static let spacingXS: CGFloat = 8
    static let spacingS: CGFloat = 12
    static let spacingM: CGFloat = 18
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 32

    static let panelPadding: CGFloat = 18
    static let panelCornerRadius: CGFloat = 24

    static let floatingDockCircleSize: CGFloat = 54
    static let floatingDockActiveWidth: CGFloat = 142
    static let floatingDockSpacing: CGFloat = 14

    static let homeSaveMin: CGFloat = 280
    static let homeSaveIdeal: CGFloat = 430
    static let homeSaveMax: CGFloat = 470

    static let homeResumeMin: CGFloat = 190
    static let homeResumeIdeal: CGFloat = 250
    static let homeResumeMax: CGFloat = 300

    static let homeInspectMin: CGFloat = 92
    static let homeInspectIdeal: CGFloat = 110
    static let homeInspectMax: CGFloat = 128

    static let homePreviewMinWidth: CGFloat = 140
    static let homePreviewIdealWidth: CGFloat = 170
    static let homePreviewMaxWidth: CGFloat = 200
    static let homePreviewHeight: CGFloat = 190

    static let heroMinWidth: CGFloat = 220
    static let heroMaxWidth: CGFloat = 290
    static let heroCircleMin: CGFloat = 180
    static let heroCircleMax: CGFloat = 250
    static let heroMetaMin: CGFloat = 88
    static let heroMetaMax: CGFloat = 108

    static let detectionColumnMinWidth: CGFloat = 220
    static let contentReadableWidth: CGFloat = 640
    static let listMinHeight: CGFloat = 220
    static let formMinFieldWidth: CGFloat = 220
    static let diagnosticsMinHeight: CGFloat = 170
    static let editorMinWidth: CGFloat = 760
    static let editorMinHeight: CGFloat = 500

    static let compactToolbarWrapWidth: CGFloat = 720
    static let compactFormWrapWidth: CGFloat = 760
    static let sessionKindMinWidth: CGFloat = 64
    static let sessionValueMinWidth: CGFloat = 220
    static let pickerMinWidth: CGFloat = 130
    static let toggleMinWidth: CGFloat = 110
}
