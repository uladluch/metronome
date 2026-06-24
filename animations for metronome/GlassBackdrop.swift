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
                .opacity(glowOn ? 0.5 : 0)
                .animation(.easeInOut(duration: 0.35), value: glowOn)
                .onAppear { print("[GlassBackdrop] Path opacity: \(glowOn ? 0.5 : 0)") }
                .onChange(of: glowOn) { oldVal, newVal in
                    print("[GlassBackdrop] GlowOn changed: \(oldVal) -> \(newVal), opacity now: \(newVal ? 0.5 : 0)")
                }
                // Верхняя кромка картинки начинается под капсулой.
                // Тулбар: padding.top 8, капсула height 60 → нижняя точка на ~68pt.
                .offset(y: 75)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}
