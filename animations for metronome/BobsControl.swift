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
                    .scaleEffect(bobBounceScales[i] * (bobPressed[i] ? 0.92 : 1.0))
                    .contentShape(Capsule())
                    .onTapGesture {
                        tapBob(at: i)
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if !bobPressed[i] {
                                    withAnimation(.easeOut(duration: 0.12)) {
                                        bobPressed[i] = true
                                    }
                                }
                            }
                            .onEnded { _ in
                                withAnimation(.easeOut(duration: 0.3)) {
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
        // Подложка: 30% серая по умолчанию. Активная вспыхивает к белому на пике удара и
        // плавно гаснет к серому вместе с pulse → к следующему удару уже серая.
        let fillOpacity = isActive ? (0.3 + 0.7 * pulse) : 0.3
        // Свечение — только у активного, его сила = pulse (синхронно с картинкой).
        let glow = isActive ? pulse : 0
        // Dome (полусфера) светлеет при нажатии.
        let domeOpacity = isPressed ? 0.24 : 0.12

        return ZStack {
            // Белая подложка ПОД стеклом, меньше на 12pt (по 6pt с каждой стороны),
            // центрирована в полноразмерном контейнере → стекло искажает её края.
            Capsule()
                .fill(.white.opacity(fillOpacity))
                .frame(width: bobWidth - 12, height: max(height - 12, 0))
                .frame(width: bobWidth, height: height, alignment: .center)

            // Стекло с интерактивностью (реагирует на нажатие — liquid glass look).
            Color.clear
                .glassEffect(.clear.interactive(), in: Capsule())
                .frame(width: bobWidth, height: height)
        }
        .frame(width: bobWidth, height: height)
        // Полусфера (dome) под стеклом, светлеет при нажатии.
        .background(alignment: .topLeading) {
            GeometryReader { g in
                let s = min(g.size.width, g.size.height)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white.opacity(domeOpacity), .white.opacity(0)],
                            center: .center,
                            startRadius: 0,
                            endRadius: s * 0.43
                        )
                    )
                    .frame(width: s * 0.87, height: s * 0.87)
                    .offset(x: -s * 0.1, y: -s * 0.1)
                    .animation(.easeOut(duration: 0.22), value: isPressed)
            }
        }
        .clipShape(Capsule())
        // Inner shadow: белый stroke с градиентом по верхней кромке.
        .overlay {
            Capsule()
                .stroke(Color.white.opacity(0.22), lineWidth: 5)
                .blur(radius: 7)
                .offset(y: 3)
                .mask(
                    Capsule().fill(
                        LinearGradient(
                            colors: [.white, .clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                )
        }
        // Свечение вокруг боба, пульсирует с ударом.
        .shadow(color: .white.opacity(0.1 + 0.45 * glow), radius: 6 + 14 * glow)
        .shadow(color: .white.opacity(0.35 * glow), radius: 28 * glow)
    }
}
