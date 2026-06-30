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

    /// Яркость свечения (0.5 — приглушено, 1 — ярко). Анимацию задаёт вызывающий
    /// (мигание идёт через withAnimation в ContentView).
    var level: Double

    var body: some View {
        ZStack(alignment: .top) {
            Image("Path")
                .resizable()
                .scaledToFit()
                .frame(width: 440)
                .blur(radius: 12)
                .opacity(level)
                // Верхняя кромка картинки начинается под капсулой.
                // Тулбар: padding.top 8, капсула height 60 → нижняя точка на ~68pt.
                .offset(y: 67)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}
