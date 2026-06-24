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
                // Центр картинки — за капсулой (тулбар отступает 8pt сверху,
                // полувысота капсулы 30pt). offset подобран так, чтобы свечение
                // оказалось под пилюлей; правится здесь.
                .offset(y: -40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .allowsHitTesting(false)
    }
}
