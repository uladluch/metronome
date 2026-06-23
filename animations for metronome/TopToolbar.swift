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
            // Кнопки видны, только пока все панели закрыты. Как только панель
            // открыта — все три кнопки скрываются: активная морфит в панель,
            // остальные не должны проступать сквозь стекло панели
            // (внутри GlassEffectContainer стекло рисуется единым проходом,
            //  и zIndex не перекрывает одно стекло другим).
            if openPanel == nil {
                GlassIconButton(
                    systemName: leftIcon,
                    glassID: PanelPosition.left.glassID,
                    namespace: namespace,
                    action: onLeft
                )

                Spacer(minLength: 0)

                GlassCapsuleButton(
                    glassID: PanelPosition.center.glassID,
                    namespace: namespace,
                    action: onCenter
                )

                Spacer(minLength: 0)

                GlassIconButton(
                    systemName: rightIcon,
                    glassID: PanelPosition.right.glassID,
                    namespace: namespace,
                    action: onRight
                )
            }
        }
        .frame(height: 60)
    }
}

// MARK: - Кнопка-иконка 60×60

/// Стеклянная кнопка 60×60 с белой SF-иконкой по центру.
///
/// Без обёртки `Button`: касание получает само `.interactive()`-стекло —
/// иначе кнопка перехватывала бы тап, и не было бы ни нативного свечения
/// на нажатии, ни корректного зацепления морфинга через glassEffectID.
private struct GlassIconButton: View {

    let systemName: String
    let glassID: String
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 22, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: 60, height: 60)
            .appGlass(in: .circle, interactive: true)
            .glassEffectID(glassID, in: namespace)
            .contentShape(Circle())
            .onTapGesture(perform: action)
            .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Центральная капсула 180×60

/// Стеклянная капсула-кнопка 180×60.
private struct GlassCapsuleButton: View {

    let glassID: String
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        Color.clear
            .frame(width: 180, height: 60)
            .appGlass(in: .capsule, interactive: true)
            .glassEffectID(glassID, in: namespace)
            .contentShape(Capsule())
            .onTapGesture(perform: action)
            .accessibilityAddTraits(.isButton)
    }
}
