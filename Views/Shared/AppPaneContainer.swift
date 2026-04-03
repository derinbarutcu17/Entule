import SwiftUI

struct AppPaneContainer<Content: View, Toolbar: View>: View {
    let content: Content
    let toolbar: Toolbar?

    init(@ViewBuilder content: () -> Content, @ViewBuilder toolbar: () -> Toolbar) {
        self.content = content()
        self.toolbar = toolbar()
    }

    init(@ViewBuilder content: () -> Content) where Toolbar == EmptyView {
        self.content = content()
        self.toolbar = nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppWindowMetrics.spacingM) {
            if let toolbar {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .center, spacing: AppWindowMetrics.spacingS) {
                        toolbar
                    }
                    VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
                        toolbar
                    }
                }
            }

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
