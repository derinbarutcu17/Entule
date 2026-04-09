import Foundation

enum AppWindowMetrics {
    static let defaultWindowWidth: CGFloat = 1080
    static let defaultWindowHeight: CGFloat = 1080
    static let minimumWindowWidth: CGFloat = 1020
    static let minimumWindowHeight: CGFloat = 680

    static let outerPadding: CGFloat = 20
    static let titlebarTopInset: CGFloat = 26
    static let shellHeaderBottomSpacing: CGFloat = 14
    static let shellContentMaxWidth: CGFloat = 980
    static let shellDockReservedWidth: CGFloat = 164

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
