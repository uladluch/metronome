//
//  ExpandableGlassMenu.swift
//  animations for metronome
//
//  Стеклянное меню, которое растёт из кнопки в полноразмерный контент.
//  Простой вариант: размер интерполируется 0→1, контент угасает/проявляется,
//  якорь — левый верхний угол кнопки.
//

import SwiftUI

struct ExpandableGlassMenu<Content: View, Label: View>: View, Animatable {

    var alignment: Alignment
    var progress: CGFloat
    var labelSize: CGSize = .init(width: 60, height: 60)
    var cornerRadius: CGFloat = 30
    @ViewBuilder var content: Content
    @ViewBuilder var label: Label

    @State private var contentSize: CGSize = .zero

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    var body: some View {
        let widthDiff = contentSize.width - labelSize.width
        let heightDiff = contentSize.height - labelSize.height

        let rWidth = widthDiff * progress
        let rHeight = heightDiff * progress

        let _ = print("[Menu] progress=\(String(format: "%.2f", progress)) contentOpacity=\(String(format: "%.2f", contentOpacity)) contentSize=\(contentSize) frame=(\(labelSize.width + rWidth)×\(labelSize.height + rHeight))")

        return ZStack(alignment: alignment) {
            // Контент в полный размер.
            content
                .onGeometryChange(for: CGSize.self, of: { $0.size }, action: { contentSize = $0 })
                .frame(width: contentSize.width, height: contentSize.height)
                .opacity(contentOpacity)
                .background(Color.red.opacity(0.1))

            // Кнопка-label сверху (угасает по мере открытия).
            ZStack(alignment: .topLeading) {
                // Dome-блик.
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white.opacity(0.12), .white.opacity(0)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 26
                        )
                    )
                    .frame(width: 52, height: 52)
                    .offset(x: -6, y: -6)

                label
            }
            .frame(width: labelSize.width, height: labelSize.height)
            .opacity(1 - labelOpacity)
        }
        .frame(width: labelSize.width + rWidth, height: labelSize.height + rHeight, alignment: alignment)
    }

    private var contentOpacity: CGFloat {
        min(max(progress - 0.35, 0) / 0.65, 1)
    }

    private var labelOpacity: CGFloat {
        min(max(progress / 0.35, 0), 1)
    }
}
