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
            Image("Path")
                .resizable()
                .scaledToFit()
                .frame(width: 440)
                // Glow всегда видно: выключено (0.5 — приглушено), включено (1 — полностью).
                .opacity(glowOn ? 1 : 0.5)
                .animation(.easeInOut(duration: 0.35), value: glowOn)
                // Верхняя кромка картинки начинается под капсулой.
                // Тулбар: padding.top 8, капсула height 60 → нижняя точка на ~68pt.
                .offset(y: 75)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}
