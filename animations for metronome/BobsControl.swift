//
//  BobsControl.swift
//  animations for metronome
//
//  Контрол «бобов» — вертикальные пилюли разных размеров (визуальный метроном).
//  Без своего тайминга: рисует по activeIndex + glowLevel из ContentView, поэтому
//  гарантированно синхронен со вспышкой картинки (один источник правды).
//
//  По умолчанию все бобы серые. На каждый удар активный боб вспыхивает белым +
//  свечение и плавно гаснет к серому — синхронно с картинкой.
//

import SwiftUI

struct BobsControl: View {

    /// Исходные размеры 4 бобов.
    private let heightVariants: [CGFloat] = [60, 90, 60, 30]
    /// Для каждого боба его цикл размеров: каждый боб циклирует через 30→60→90→30.
    /// Начинает со своего исходного размера в варианте 0.
    private let bobSizeCycles: [[CGFloat]] = [
        [60, 30, 90],     // боб 0: средний → маленький → большой
        [90, 60, 30],     // боб 1: большой → средний → маленький
        [60, 30, 90],     // боб 2: средний → маленький → большой
        [30, 60, 90]      // боб 3: маленький → средний → большой
    ]
    private let bobWidth: CGFloat = 40

    /// Индекс боба, который сейчас «на удар» (приходит из ContentView, % 4).
    var activeIndex: Int = 0
    /// Включён ли glow (метроном бьётся).
    var glowOn: Bool = false
    /// Яркость вспышки: 0.5 — затухло, 1.0 — пик удара. Тот же источник, что и картинка.
    var glowLevel: Double = 0.5

    /// Для каждого боба (индекс 0-3): его текущий вариант размера (0, 1, 2).
    @State private var bobSizeModes: [Int] = [0, 0, 0, 0]
    /// Для каждого боба: масштаб для bounce анимации.
    @State private var bobBounceScales: [CGFloat] = [1, 1, 1, 1]
    /// Для каждого боба: нажат ли (визуальная обратная связь).
    @State private var bobPressed: [Bool] = [false, false, false, false]

    /// Нормализованная сила удара: 0 (затухло) … 1 (пик). Из glowLevel 0.5…1.0.
    private var pulse: Double {
        max(0, min(1, (glowLevel - 0.5) / 0.5))
    }

    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            ForEach(heightVariants.indices, id: \.self) { i in
                let height = bobSizeCycles[i][bobSizeModes[i]]
                bob(height: height, isActive: glowOn && i == activeIndex, isPressed: bobPressed[i])
                    .scaleEffect(bobBounceScales[i] * (bobPressed[i] ? 1.1 : 1.0))
                    .contentShape(Capsule())
                    .onTapGesture {
                        tapBob(at: i)
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if !bobPressed[i] {
                                    withAnimation(.easeOut(duration: 0.06)) {
                                        bobPressed[i] = true
                                    }
                                }
                            }
                            .onEnded { _ in
                                withAnimation(.easeOut(duration: 0.12)) {
                                    bobPressed[i] = false
                                }
                            }
                    )
            }
        }
        .frame(height: 90)  // высота максимального боба — контейнер фиксирован
    }

    private func tapBob(at index: Int) {
        // Haptic feedback
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        // Смещение размера только этого боба (0 → 1 → 2 → 0)
        bobSizeModes[index] = (bobSizeModes[index] + 1) % 3

        // Bounce анимация для этого боба
        withAnimation(.interpolatingSpring(stiffness: 150, damping: 8)) {
            bobBounceScales[index] = 0.95
        }
        withAnimation(.interpolatingSpring(stiffness: 150, damping: 8).delay(0.05)) {
            bobBounceScales[index] = 1.0
        }
    }

    private func bob(height: CGFloat, isActive: Bool, isPressed: Bool) -> some View {
        let fillOpacity = isActive ? pulse : 0

        return ZStack {
            // Белая вспышка ПОД стеклом (в покое прозрачна → боб тёмный как кнопка).
            Capsule()
                .fill(.white.opacity(fillOpacity))
                .frame(width: bobWidth - 12, height: max(height - 12, 0))
                .frame(width: bobWidth, height: height, alignment: .center)

            // Стекло с интерактивностью — чистый clear glass.
            Color.clear
                .glassEffect(.clear.interactive(), in: Capsule())
                .frame(width: bobWidth, height: height)
        }
        .frame(width: bobWidth, height: height)
        .clipShape(Capsule())
    }
}
