//
//  ExpandableGlassMenu.swift
//  animations for metronome
//
//  Стеклянное меню, которое ПЛАВНО вырастает из кнопки (label) в полноразмерный
//  контент (content) — паттерн «expandable glass» (Kavsoft).
//
//  Принцип: это ОДИН стеклянный элемент. Его размер интерполируется от labelSize
//  до измеренного размера контента по мере progress 0→1. Контент измеряется через
//  onGeometryChange + fixedSize. label угасает в начале, content проявляется к концу,
//  по центру морфа добавляется лёгкий blur («жидкость»). Conformance к Animatable
//  даёт покадровую анимацию progress — поэтому форма морфит плавно, а не скачком.
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

    // Анимируем именно progress — покадрово.
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    var body: some View {
        // Насколько контент больше кнопки.
        let widthDiff = contentSize.width - labelSize.width
        let heightDiff = contentSize.height - labelSize.height

        // Размер тянется за ПОЛНЫМ progress (0→1), а не за contentOpacity.
        // Иначе рост идёт в конце морфа, а сжатие — в начале → асимметрия.
        // Линейная привязка к progress делает открытие и закрытие зеркальными.
        let rWidth = widthDiff * progress
        let rHeight = heightDiff * progress

        let _ = print("[ExpandableGlassMenu] progress: \(progress), contentOpacity: \(contentOpacity), contentScale: \(contentScale), contentSize: \(contentSize)")

        return ZStack(alignment: alignment) {
            // Контент (стекло даёт внешний GlassEffectContainer).
            content
                .fixedSize()
                .onGeometryChange(for: CGSize.self, of: { $0.size }, action: { contentSize = $0 })
                .frame(width: labelSize.width + rWidth, height: labelSize.height + rHeight, alignment: .topLeading)
                .scaleEffect(contentScale, anchor: scaleAnchor)
                .blur(radius: 14 * blurProgress)
                .opacity(contentOpacity)

            // Кнопка-источник (шестерёнка) сверху — видна в начале, угасает по мере открытия.
            // Dome-эффект (белый блик в верхнем левом углу) — как на других стеклянных кнопках.
            ZStack(alignment: .topLeading) {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .white.opacity(0.12),
                                .white.opacity(0)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 26
                        )
                    )
                    .frame(width: 52, height: 52)
                    .offset(x: -6, y: -6)
                    .opacity(1 - labelOpacity)  // Блик угасает вместе с кнопкой

                label
                    .compositingGroup()
                    .blur(radius: 14 * blurProgress)
                    .opacity(1 - labelOpacity)
                    .frame(width: labelSize.width, height: labelSize.height)
            }
            .frame(width: labelSize.width, height: labelSize.height)
        }
    }

    // MARK: - Производные от progress

    /// Контент проявляется в последние 65% морфа.
    private var contentOpacity: CGFloat {
        max(progress - 0.35, 0) / 0.65
    }

    /// Кнопка-label угасает в первые 35% морфа.
    private var labelOpacity: CGFloat {
        min(progress / 0.35, 1)
    }

    /// Blur максимален на середине (0.5), на концах = 0.
    private var blurProgress: CGFloat {
        progress > 0.5 ? (1 - progress) / 0.5 : progress / 0.5
    }

    /// Контент масштабируется от «размера кнопки» (мелкий) к 1.
    private var contentScale: CGFloat {
        guard contentSize.width > 0, contentSize.height > 0 else { return 1 }
        let minAspectScale = min(labelSize.width / contentSize.width,
                                 labelSize.height / contentSize.height)
        return minAspectScale + (1 - minAspectScale) * contentOpacity
    }

    /// Якорь масштабирования — совпадает с alignment, чтобы рост шёл из угла кнопки.
    private var scaleAnchor: UnitPoint {
        switch alignment {
        case .bottomLeading:  return .bottomLeading
        case .bottom:         return .bottom
        case .bottomTrailing: return .bottomTrailing
        case .topLeading:     return .topLeading
        case .top:            return .top
        case .topTrailing:    return .topTrailing
        case .leading:        return .leading
        case .trailing:       return .trailing
        default:              return .center
        }
    }
}
