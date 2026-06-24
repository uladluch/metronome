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

    var body: some View {
        ZStack(alignment: .top) {
            Image("Path")
                .resizable()
                .scaledToFit()
                .frame(width: 440)
                .opacity(0.5)
                // Верхняя кромка картинки на уровне верхней кромки капсулы.
                // Тулбар: padding.top 8, капсула height 60. Центр капсулы на ~38pt.
                .offset(y: 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}
