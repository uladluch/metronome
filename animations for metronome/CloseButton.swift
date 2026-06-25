//
//  CloseButton.swift
//  animations for metronome
//
//  Единая кнопка закрытия (крестик) для всех оверлеев и sheet'ов.
//  44×44, полностью Liquid Glass (.clear). Один источник правды.
//
//  ВАЖНО: НЕ класть в ToolbarItem — там iOS 26 сама оборачивает в стекло,
//  получится «кнопка в кнопке». Ставить вручную (overlay / HStack).
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
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .appGlass(in: Circle(), interactive: true)  // clear glass, 44×44
        }
        .buttonStyle(.plain)
    }
}
