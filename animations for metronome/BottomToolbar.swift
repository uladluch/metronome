//
//  BottomToolbar.swift
//  animations for metronome
//
//  Нижний тулбар: по бокам такие же стеклянные кнопки 60×60, что и сверху,
//  а по центру — нативный SwiftUI Slider (вместо капсулы).
//

import SwiftUI

struct BottomToolbar: View {

    // Кнопки тут не морфят, namespace нужен только для сигнатуры.
    @Namespace private var ns

    @State private var value: Double = 0.5

    private let leftIcon = "minus"
    private let rightIcon = "plus"

    var body: some View {
        HStack(spacing: 16) {
            GlassIconButton(
                systemName: leftIcon,
                glassID: nil,
                namespace: ns,
                action: {}
            )

            // Нативный слайдер по центру.
            Slider(value: $value)

            GlassIconButton(
                systemName: rightIcon,
                glassID: nil,
                namespace: ns,
                action: {}
            )
        }
        .frame(height: 60)
        .padding(.horizontal, 16)
    }
}
