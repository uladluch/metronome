//
//  BobsControl.swift
//  animations for metronome
//
//  Контрол «бобов» — вертикальные пилюли разных размеров.
//  Обычный боб: белый 50% + стекло (.clear) той же формы.
//  Активный боб: полностью белый (без прозрачности) + свечение вокруг.
//  Все шириной 40pt, gap 6pt, выровнены по центру.
//

import SwiftUI

struct BobsControl: View {

    /// Высоты 4 бобов из трёх типов: средний 60, длинный 90, средний 60, короткий 30.
    /// (Первый и третий одинаковые.)
    private let heights: [CGFloat] = [60, 90, 60, 30]
    private let bobWidth: CGFloat = 40

    /// Индекс активного боба (полностью белый + свечение).
    var activeIndex: Int = 0

    var body: some View {
        HStack(spacing: 6) {
            ForEach(heights.indices, id: \.self) { i in
                bob(height: heights[i], isActive: i == activeIndex)
            }
        }
    }

    private func bob(height: CGFloat, isActive: Bool) -> some View {
        Capsule()
            .fill(.white.opacity(isActive ? 1.0 : 0.5))   // активный — без прозрачности
            .frame(width: bobWidth, height: height)
            .glassEffect(.clear, in: Capsule())
            // Свечение вокруг активного боба.
            .shadow(color: .white.opacity(isActive ? 0.9 : 0.2), radius: isActive ? 16 : 6)
            .shadow(color: .white.opacity(isActive ? 0.55 : 0), radius: isActive ? 32 : 0)
            .animation(.easeInOut(duration: 0.25), value: isActive)
    }
}
