//
//  GlassPanel.swift
//  animations for metronome
//
//  Внутренний контент панели, который раскрывается из шестерёнки через
//  ExpandableGlassMenu. Стекло/форму/морф даёт сам ExpandableGlassMenu —
//  здесь только крестик закрытия (LG кнопка) в верхнем правом углу.
//

import SwiftUI

struct PanelContent: View {

    @Namespace private var ns
    var onClose: () -> Void

    var body: some View {
        VStack {
            HStack {
                Spacer()
                GlassButton(
                    shape: Circle(),
                    namespace: ns,
                    action: onClose,
                    showDome: true
                ) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                }
            }
            Spacer()
        }
        .padding(20)
    }
}
