import SwiftUI

/// Main container view that renders the entire split tree (internal implementation)
struct SplitViewContainer<Content: View, EmptyContent: View>: View {
    @Environment(SplitViewController.self) private var controller

    let contentBuilder: (TabItem, PaneID) -> Content
    let emptyPaneBuilder: (PaneID) -> EmptyContent
    let appearance: BonsplitConfiguration.Appearance
    var showSplitButtons: Bool = true
    var hideSingleTabBar: Bool = false
    var contentViewLifecycle: ContentViewLifecycle = .recreateOnSwitch
    var onGeometryChange: ((_ isDragging: Bool) -> Void)?
    var enableAnimations: Bool = true
    var animationDuration: Double = 0.15

    var body: some View {
        GeometryReader { geometry in
            splitNodeContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .focusable()
                .focusEffectDisabled()
                .onChange(of: geometry.size) { _, newSize in
                    updateContainerFrame(geometry: geometry)
                }
                .onAppear {
                    updateContainerFrame(geometry: geometry)
                }
        }
    }

    private func updateContainerFrame(geometry: GeometryProxy) {
        // Get frame in global coordinate space
        let frame = geometry.frame(in: .global)
        let previousFrame = controller.containerFrame
        let frameChanged =
            abs(previousFrame.origin.x - frame.origin.x) > 0.5 ||
            abs(previousFrame.origin.y - frame.origin.y) > 0.5 ||
            abs(previousFrame.size.width - frame.size.width) > 0.5 ||
            abs(previousFrame.size.height - frame.size.height) > 0.5
        guard frameChanged else { return }

        DispatchQueue.main.async {
            let latestFrame = controller.containerFrame
            let stillChanged =
                abs(latestFrame.origin.x - frame.origin.x) > 0.5 ||
                abs(latestFrame.origin.y - frame.origin.y) > 0.5 ||
                abs(latestFrame.size.width - frame.size.width) > 0.5 ||
                abs(latestFrame.size.height - frame.size.height) > 0.5
            guard stillChanged else { return }
            controller.containerFrame = frame
        }
    }

    @ViewBuilder
    private var splitNodeContent: some View {
        let nodeToRender = controller.zoomedNode ?? controller.rootNode
        SplitNodeView(
            node: nodeToRender,
            contentBuilder: contentBuilder,
            emptyPaneBuilder: emptyPaneBuilder,
            appearance: appearance,
            showSplitButtons: showSplitButtons,
            hideSingleTabBar: hideSingleTabBar,
            contentViewLifecycle: contentViewLifecycle,
            onGeometryChange: onGeometryChange,
            enableAnimations: enableAnimations,
            animationDuration: animationDuration
        )
    }
}
