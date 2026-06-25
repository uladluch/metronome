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

    /// Три варианта высот: маленький, средний, большой.
    private let heightVariants: [[CGFloat]] = [
        [60, 90, 60, 30],      // вариант 0: средний, большой, средний, маленький
        [30, 60, 90, 60],      // вариант 1: маленький, средний, большой, средний (ротация)
        [90, 60, 30, 60]       // вариант 2: большой, средний, маленький, средний (ротация)
    ]
    private let bobWidth: CGFloat = 40

    /// Индекс боба, который сейчас «на удар» (приходит из ContentView, % 4).
    var activeIndex: Int = 0
    /// Включён ли glow (метроном бьётся).
    var glowOn: Bool = false
    /// Яркость вспышки: 0.5 — затухло, 1.0 — пик удара. Тот же источник, что и картинка.
    var glowLevel: Double = 0.5

    /// Текущий вариант размеров (0, 1, 2) — циклируется при тапе.
    @State private var sizeMode: Int = 0
    /// Масштаб для bounce анимации (при тапе).
    @State private var bounceScale: CGFloat = 1.0

    private var heights: [CGFloat] { heightVariants[sizeMode] }

    /// Нормализованная сила удара: 0 (затухло) … 1 (пик). Из glowLevel 0.5…1.0.
    private var pulse: Double {
        max(0, min(1, (glowLevel - 0.5) / 0.5))
    }

    var body: some View {
        HStack(spacing: 6) {
            ForEach(heights.indices, id: \.self) { i in
                bob(height: heights[i], isActive: glowOn && i == activeIndex)
                    .scaleEffect(bounceScale)
                    .onTapGesture {
                        tapBob()
                    }
            }
        }
    }

    private func tapBob() {
        // Haptic feedback
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        // Смещение размеров вперёд на один вариант (ротация 0 → 1 → 2 → 0)
        sizeMode = (sizeMode + 1) % 3

        // Bounce анимация: вниз до 0.95, обратно до 1.0
        withAnimation(.interpolatingSpring(stiffness: 150, damping: 8)) {
            bounceScale = 0.95
        }
        withAnimation(.interpolatingSpring(stiffness: 150, damping: 8).delay(0.05)) {
            bounceScale = 1.0
        }
    }

    private func bob(height: CGFloat, isActive: Bool) -> some View {
        // Подложка: 36% серая по умолчанию. Активная вспыхивает к белому на пике удара и
        // плавно гаснет к серому вместе с pulse → к следующему удару уже серая.
        let fillOpacity = isActive ? (0.36 + 0.64 * pulse) : 0.36
        // Свечение — только у активного, его сила = pulse (синхронно с картинкой).
        let glow = isActive ? pulse : 0

        return ZStack {
            // Белая подложка ПОД стеклом, меньше на 12pt (по 6pt с каждой стороны),
            // центрирована в полноразмерном контейнере → стекло искажает её края.
            Capsule()
                .fill(.white.opacity(fillOpacity))
                .frame(width: bobWidth - 12, height: max(height - 12, 0))
                .frame(width: bobWidth, height: height, alignment: .center)

            // Стекло с интерактивностью (реагирует на нажатие — liquid glass look).
            Color.clear
                .glassEffect(.regular.interactive(), in: Capsule())
                .frame(width: bobWidth, height: height)
        }
        .frame(width: bobWidth, height: height)
        // Свечение вокруг боба, пульсирует с ударом.
        .shadow(color: .white.opacity(0.1 + 0.45 * glow), radius: 6 + 14 * glow)
        .shadow(color: .white.opacity(0.35 * glow), radius: 28 * glow)
        .contentShape(Capsule())  // точный hit-box для тапа
    }
}
