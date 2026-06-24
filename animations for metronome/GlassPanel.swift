//
//  GlassPanel.swift
//  animations for metronome
//
//  Внутренний контент панели, который раскрывается из шестерёнки через
//  ExpandableGlassMenu. Стекло/форму/морф даёт сам ExpandableGlassMenu —
//  здесь только крестик закрытия в верхнем правом углу.
//

import SwiftUI

struct PanelContent: View {

    var onClose: () -> Void

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(Color.white.opacity(0.18)))
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(20)
    }
}
