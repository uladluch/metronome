//
//  CloseButton.swift
//  animations for metronome
//
//  Единая кнопка закрытия (крестик). 40×40, круглое Liquid Glass.
//  glassEffect с явной формой Circle() — поэтому не «расплющивается» и НЕ
//  превращается в квадрат при нажатии (форма зафиксирована).
//
//  ВАЖНО: НЕ класть в ToolbarItem — там iOS сама добавляет стекло → «кнопка в
//  кнопке». Ставить через .overlay / HStack.
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
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .glassEffect(.regular.interactive(), in: Circle())
        }
        .buttonStyle(.plain)
    }
}
