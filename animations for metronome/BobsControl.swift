//
//  BobsControl.swift
//  animations for metronome
//
//  Контрол «бобов» — вертикальные светящиеся пилюли разных размеров.
//  Каждый боб: белый цвет (opacity 50%), поверх — стекло того же формата (.clear).
//  Все шириной 40pt, gap 6pt, выровнены по центру. Лёгкое свечение.
//

import SwiftUI

struct BobsControl: View {

    /// Высоты 4 бобов (разные размеры). Средний 60, длинный 90, короткий 30.
    private let heights: [CGFloat] = [70, 90, 60, 30]

    private let bobWidth: CGFloat = 40

    var body: some View {
        HStack(spacing: 6) {
            ForEach(heights.indices, id: \.self) { i in
                bob(height: heights[i])
            }
        }
    }

    private func bob(height: CGFloat) -> some View {
        Capsule()
            .fill(.white.opacity(0.5))            // белый 50%
            .frame(width: bobWidth, height: height)
            .glassEffect(.clear, in: Capsule())   // сверху стекло той же формы
            .shadow(color: .white.opacity(0.25), radius: 8)  // лёгкое свечение
    }
}
