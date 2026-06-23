//
//  GlassBackdrop.swift
//  animations for metronome
//
//  Зелёное свечение (луч) ПОД стеклом по центру — за капсулой.
//
//  Liquid Glass преломляет и отражает то, что под ним. Капсула сделана из
//  `.clear`-стекла, поэтому этот зелёный свет преломляется прямо под пилюлей
//  (lensing). Свет собран по центру и приглушён к краям, так что боковые кнопки
//  остаются на чёрном; лёгкое «дыхание» делает свечение живым.
//

import SwiftUI

struct GlassBackdrop: View {

    @State private var pulse = false

    /// Сочный травяной зелёный.
    private let green = Color(red: 0.48, green: 0.88, blue: 0.13)

    var body: some View {
        ZStack(alignment: .top) {
            ZStack {
                // Широкое мягкое гало.
                Ellipse()
                    .fill(green)
                    .frame(width: 380, height: 300)
                    .blur(radius: 100)
                    .opacity(0.30)

                // Средний слой.
                Ellipse()
                    .fill(green)
                    .frame(width: 260, height: 200)
                    .blur(radius: 60)
                    .opacity(0.50)

                // Яркое ядро прямо за пилюлей.
                Ellipse()
                    .fill(green)
                    .frame(width: 150, height: 110)
                    .blur(radius: 35)
                    .opacity(0.70)
            }
            // Центр свечения — за капсулой (тулбар отступает 8pt сверху,
            // полувысота капсулы 30pt → ~38pt от верха safe area).
            .offset(y: 38)
            .scaleEffect(pulse ? 1.05 : 0.95)
            .animation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true), value: pulse)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .allowsHitTesting(false)
        .onAppear { pulse = true }
    }
}
