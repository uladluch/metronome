//
//  CloseButton.swift
//  animations for metronome
//
//  Единая НАТИВНАЯ кнопка закрытия (крестик) для всех оверлеев и sheet'ов.
//  44×44, системный Liquid Glass стиль (.buttonStyle(.glass)) — тот же, что
//  тулбар применяет автоматически, но вызванный standalone.
//
//  ВАЖНО:
//  - НЕ класть в ToolbarItem — там iOS сама оборачивает в стекло → «кнопка в кнопке».
//    Ставить через .overlay / HStack.
//  - .clipShape(Circle()) обязателен — без него .buttonStyle(.glass) даёт
//    rendering artifacts (кнопку «расплющивает»).
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
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.glass)         // системный Liquid Glass стиль (нативный)
        .buttonBorderShape(.circle)  // круглая форма
        .clipShape(Circle())         // фикс rendering artifacts (иначе плющит)
    }
}
