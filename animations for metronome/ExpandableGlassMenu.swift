//
//  ExpandableGlassMenu.swift
//  animations for metronome
//
//  Стеклянное меню, которое вырастает из кнопки (label) в полноразмерный контент.
//  ОДИН стеклянный элемент: рамка растёт от labelSize до измеренного размера
//  контента по мере progress 0→1, контент проявляется, label угасает. Стекло —
//  своё (внутренний GlassEffectContainer), якорь роста — alignment (угол кнопки).
//

import SwiftUI

struct ExpandableGlassMenu<Content: View, Label: View>: View, Animatable {

    var alignment: Alignment
    var progress: CGFloat
    var labelSize: CGSize = .init(width: 60, height: 60)
    var cornerRadius: CGFloat = 30
    @ViewBuilder var content: Content
    @ViewBuilder var label: Label

    /// Измеренный натуральный размер контента.
    @State private var contentSize: CGSize = .zero

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    var body: some View {
        // Рамка растёт линейно с progress — от кнопки до полного контента.
        let rWidth = (contentSize.width - labelSize.width) * progress
        let rHeight = (contentSize.height - labelSize.height) * progress

        GlassEffectContainer {
            ZStack(alignment: alignment) {
                // Контент в натуральную величину; рамка обрезает его по мере роста.
                content
                    .fixedSize()
                    .onGeometryChange(for: CGSize.self, of: { $0.size }, action: { contentSize = $0 })
                    .opacity(contentOpacity)

                // Кнопка-источник (шестерёнка) + dome-блик, угасает по мере открытия.
                ZStack(alignment: .topLeading) {
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
            // Рамка-окно: от кнопки до полного размера, якорь — угол кнопки.
            .frame(width: labelSize.width + rWidth,
                   height: labelSize.height + rHeight,
                   alignment: alignment)
            .clipShape(.rect(cornerRadius: cornerRadius))
            .contentShape(.rect(cornerRadius: cornerRadius))  // тапы только по видимой форме
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
        }
    }

    // MARK: - Производные от progress (зажаты в [0,1] чтобы spring bounce не ломал)

    /// Контент проявляется в последние 65% морфа.
    private var contentOpacity: CGFloat {
        min(max(progress - 0.35, 0) / 0.65, 1)
    }

    /// Кнопка-label угасает в первые 35% морфа.
    private var labelOpacity: CGFloat {
        min(max(progress / 0.35, 0), 1)
    }
}
