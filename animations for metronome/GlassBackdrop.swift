//
//  GlassBackdrop.swift
//  animations for metronome
//
//  Картинка-свечение (ассет `Path`) ПОД стеклом по центру — за капсулой.
//
//  Liquid Glass преломляет и отражает то, что под ним. Капсула из `.clear`-стекла,
//  поэтому это свечение преломляется прямо под пилюлей (lensing).
//

import SwiftUI

struct GlassBackdrop: View {

    /// Подсветка вкл/выкл — управляет видимостью свечения Path.
    var glowOn: Bool

    var body: some View {
        ZStack(alignment: .top) {
            // Тест: простой градиент вместо Image("Path") для проверки видимости.
            LinearGradient(
                colors: [
                    Color.green.opacity(0.4),
                    Color.cyan.opacity(0.2),
                    .clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: 440, height: 200)
            .opacity(glowOn ? 1 : 0.5)
            .animation(.easeInOut(duration: 0.35), value: glowOn)
            .offset(y: 75)
            .onAppear { print("[GlassBackdrop] Gradient rendered, opacity: \(glowOn ? 1 : 0.5)") }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear { print("[GlassBackdrop] Body rendered, glowOn: \(glowOn)") }
        .onChange(of: glowOn) { oldVal, newVal in
            print("[GlassBackdrop] glowOn changed: \(oldVal) -> \(newVal), opacity now: \(newVal ? 1 : 0.5)")
        }
    }
}
