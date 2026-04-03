import CoreGraphics

enum HomeLayoutTier: Equatable {
    case wide
    case medium
    case compact
}

struct HomeLayoutFrames: Equatable {
    var tier: HomeLayoutTier
    var titleOrigin: CGPoint
    var saveFrame: CGRect
    var resumeFrame: CGRect
    var previewFrame: CGRect
    var inspectFrame: CGRect
    var utilityFrame: CGRect
    var utilitySpacing: CGFloat
}

enum HomeLayout {
    static func make(in contentSize: CGSize) -> HomeLayoutFrames {
        let width = max(contentSize.width, AppWindowMetrics.minimumWindowWidth - (AppWindowMetrics.outerPadding * 2))
        let height = max(contentSize.height, AppWindowMetrics.minimumWindowHeight - (AppWindowMetrics.outerPadding * 2))

        let tier: HomeLayoutTier
        if width >= 1180 && height >= 720 {
            tier = .wide
        } else if width >= 980 && height >= 620 {
            tier = .medium
        } else {
            tier = .compact
        }

        let titleOrigin = CGPoint(x: 24, y: 14)
        let usableWidth = width - AppWindowMetrics.homeRightDockInset
        let saveSize = clamp(width * (tier == .wide ? 0.34 : tier == .medium ? 0.32 : 0.30),
                             min: AppWindowMetrics.homeSaveMin,
                             ideal: AppWindowMetrics.homeSaveIdeal,
                             max: AppWindowMetrics.homeSaveMax)
        let resumeSize = clamp(width * (tier == .wide ? 0.22 : tier == .medium ? 0.24 : 0.26),
                               min: AppWindowMetrics.homeResumeMin,
                               ideal: AppWindowMetrics.homeResumeIdeal,
                               max: AppWindowMetrics.homeResumeMax)
        let inspectSize = clamp(width * 0.095,
                                min: AppWindowMetrics.homeInspectMin,
                                ideal: AppWindowMetrics.homeInspectIdeal,
                                max: AppWindowMetrics.homeInspectMax)

        let previewWidth = clamp(width * (tier == .wide ? 0.16 : tier == .medium ? 0.18 : 0.22),
                                 min: AppWindowMetrics.homePreviewMinWidth,
                                 ideal: AppWindowMetrics.homePreviewIdealWidth,
                                 max: AppWindowMetrics.homePreviewMaxWidth)
        let previewHeight = tier == .compact ? AppWindowMetrics.homePreviewCompactHeight : AppWindowMetrics.homePreviewHeight

        let saveX: CGFloat = tier == .compact ? 90 : 70
        let saveY = tier == .wide ? height * 0.30 : tier == .medium ? height * 0.35 : height * 0.42
        let saveFrame = CGRect(x: saveX, y: saveY, width: saveSize, height: saveSize)

        let clusterGap = tier == .wide ? AppWindowMetrics.homeClusterGapWide : tier == .medium ? AppWindowMetrics.homeClusterGapMedium : AppWindowMetrics.homeClusterGapCompact

        let resumeX = min(max(saveFrame.maxX + clusterGap, width * 0.52), usableWidth - resumeSize - previewWidth - AppWindowMetrics.homeClusterGapCompact)
        let resumeY: CGFloat = tier == .compact ? 92 : 76
        let resumeFrame = CGRect(x: resumeX, y: resumeY, width: resumeSize, height: resumeSize)

        let previewFrame: CGRect
        let inspectFrame: CGRect
        switch tier {
        case .wide, .medium:
            let previewX = min(resumeFrame.maxX + (tier == .wide ? 22 : 18), usableWidth - previewWidth)
            let previewY = resumeFrame.minY + (tier == .wide ? 54 : 48)
            previewFrame = CGRect(x: previewX, y: previewY, width: previewWidth, height: previewHeight)

            let inspectX = previewFrame.midX - inspectSize / 2
            let inspectY = previewFrame.maxY + 24
            inspectFrame = CGRect(x: inspectX, y: inspectY, width: inspectSize, height: inspectSize)
        case .compact:
            let previewX = min(resumeFrame.minX + 18, usableWidth - previewWidth)
            let previewY = resumeFrame.maxY + 20
            previewFrame = CGRect(x: previewX, y: previewY, width: previewWidth, height: previewHeight)

            let inspectX = min(previewFrame.maxX + 18, usableWidth - inspectSize)
            let inspectY = previewFrame.maxY - inspectSize * 0.78
            inspectFrame = CGRect(x: inspectX, y: inspectY, width: inspectSize, height: inspectSize)
        }

        let utilityWidth = tier == .compact ? AppWindowMetrics.homeUtilityCompactWidth : AppWindowMetrics.homeUtilityWidth
        let utilityHeight = tier == .compact ? AppWindowMetrics.homeUtilityCompactHeight : AppWindowMetrics.homeUtilityHeight
        let utilityStackHeight = utilityHeight * 2 + AppWindowMetrics.homeUtilityGap
        let utilityFrame = CGRect(
            x: width - utilityWidth - AppWindowMetrics.homeUtilityEdgeInset,
            y: height - utilityStackHeight - AppWindowMetrics.homeUtilityBottomInset,
            width: utilityWidth,
            height: utilityStackHeight
        )

        return HomeLayoutFrames(
            tier: tier,
            titleOrigin: titleOrigin,
            saveFrame: saveFrame,
            resumeFrame: resumeFrame,
            previewFrame: previewFrame,
            inspectFrame: inspectFrame,
            utilityFrame: utilityFrame,
            utilitySpacing: AppWindowMetrics.homeUtilityGap
        )
    }

    private static func clamp(_ value: CGFloat, min: CGFloat, ideal: CGFloat, max: CGFloat) -> CGFloat {
        Swift.max(min, Swift.min(max, value == 0 ? ideal : value))
    }
}
