//
//  TopToolbar.swift
//  animations for metronome
//
//  Верхний тулбар: левая и правая стеклянные кнопки 60×60
//  и центральная стеклянная капсула 180×60.
//

import SwiftUI

struct TopToolbar: View {

    /// Шаблонные SF Symbols — заменим на финальные иконки позже.
    private let leftIcon = "gearshape"
    private let rightIcon = "ellipsis"

    var body: some View {
        // Контейнер позволяет стеклянным элементам корректно
        // взаимодействовать и плавно «перетекать» друг в друга.
        GlassEffectContainer(spacing: 16) {
            HStack(spacing: 0) {
                ToolbarIconButton(systemName: leftIcon) {
                    // действие добавим позже
                }

                Spacer(minLength: 0)

                // Центральная капсула Liquid Glass.
                Color.clear
                    .frame(width: 180, height: 60)
                    .appGlass(in: .capsule)

                Spacer(minLength: 0)

                ToolbarIconButton(systemName: rightIcon) {
                    // действие добавим позже
                }
            }
        }
    }
}

// MARK: - Кнопка тулбара

/// Стеклянная кнопка 60×60 с белой SF-иконкой по центру.
private struct ToolbarIconButton: View {

    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .appGlass(in: .circle, interactive: true)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        VStack {
            TopToolbar()
                .padding(.horizontal, 16)
            Spacer()
        }
    }
    .preferredColorScheme(.dark)
}
