//
//  TopToolbar.swift
//  animations for metronome
//
//  Верхний тулбар: левая и правая стеклянные кнопки 60×60
//  и центральная стеклянная капсула 180×60.
//
//  Каждый стеклянный элемент несёт glassEffectID — это «якорь» для морфинга
//  в соответствующую панель. Когда панель открыта, её кнопка скрывается
//  (её место занимает прозрачный placeholder, чтобы раскладка не прыгала),
//  а стекло «перетекает» в панель с тем же id.
//

import SwiftUI

struct TopToolbar: View {

    let namespace: Namespace.ID
    let openPanel: PanelPosition?

    let onLeft: () -> Void
    let onCenter: () -> Void
    let onRight: () -> Void

    private let leftIcon = "gearshape"
    private let rightIcon = "ellipsis"

    var body: some View {
        HStack(spacing: 0) {
            // Левая кнопка
            if openPanel == .left {
                placeholder(width: 60)
            } else {
                GlassIconButton(
                    systemName: leftIcon,
                    glassID: PanelPosition.left.glassID,
                    namespace: namespace,
                    action: onLeft
                )
            }

            Spacer(minLength: 0)

            // Центральная капсула
            if openPanel == .center {
                placeholder(width: 180)
            } else {
                GlassCapsuleButton(
                    glassID: PanelPosition.center.glassID,
                    namespace: namespace,
                    action: onCenter
                )
            }

            Spacer(minLength: 0)

            // Правая кнопка
            if openPanel == .right {
                placeholder(width: 60)
            } else {
                GlassIconButton(
                    systemName: rightIcon,
                    glassID: PanelPosition.right.glassID,
                    namespace: namespace,
                    action: onRight
                )
            }
        }
    }

    /// Прозрачная «дырка» размером с кнопку — держит раскладку, пока кнопка
    /// превратилась в панель.
    private func placeholder(width: CGFloat) -> some View {
        Color.clear.frame(width: width, height: 60)
    }
}

// MARK: - Кнопка-иконка 60×60

/// Стеклянная кнопка 60×60 с белой SF-иконкой по центру.
private struct GlassIconButton: View {

    let systemName: String
    let glassID: String
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .appGlass(in: .circle, interactive: true)
                .glassEffectID(glassID, in: namespace)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Центральная капсула 180×60

/// Стеклянная капсула-кнопка 180×60.
private struct GlassCapsuleButton: View {

    let glassID: String
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Color.clear
                .frame(width: 180, height: 60)
                .appGlass(in: .capsule, interactive: true)
                .glassEffectID(glassID, in: namespace)
        }
        .buttonStyle(.plain)
    }
}
