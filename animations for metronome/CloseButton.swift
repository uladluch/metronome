//
//  CloseButton.swift
//  animations for metronome
//
//  Единая кнопка закрытия (крестик) для всех оверлеев и sheet'ов.
//  Один источник правды — меняешь тут, меняется везде.
//

import SwiftUI

struct CloseButton: View {

    var action: () -> Void

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }) {
            Image(systemName: "xmark")
        }
        .buttonStyle(.glass)        // нативная iOS 26 glass-кнопка
        .buttonBorderShape(.circle) // круглая
    }
}
