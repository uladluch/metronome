//
//  TopToolbar.swift
//  animations for metronome
//
//  Верхний тулбар: левая и правая стеклянные кнопки 60×60
//  и центральная стеклянная капсула 180×60.
//
//  Морф-расширение в панель есть только у шестерёнки (левая кнопка) — у неё
//  glassEffectID, и её стекло «перетекает» в левую панель. Когда открыта любая
//  панель, остальные кнопки просто прячутся ПО МЕСТУ (opacity), не двигаясь:
//  слоты в HStack фиксированы (у шестерёнки — прозрачный placeholder, пока она
//  морфит), поэтому раскладка не «разъезжается».
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
            // Пока панель открыта — кнопки убираются полностью (а не прячутся по
            // opacity: на стеклянном элементе opacity не гасит иконку надёжно).
            // Placeholder держит ширину слота, поэтому раскладка не «разъезжается».
            if openPanel == nil {
                GlassIconButton(
                    systemName: leftIcon,
                    glassID: PanelPosition.left.glassID,
                    namespace: namespace,
                    action: onLeft
                )
            } else {
                placeholder(width: 60)
            }

            Spacer(minLength: 0)

            if openPanel == nil {
                GlassCapsuleButton(
                    glassID: nil,                 // без морфинга → не уезжает, просто пропадает
                    namespace: namespace,
                    action: {}
                )
            } else {
                placeholder(width: 180)
            }

            Spacer(minLength: 0)

            if openPanel == nil {
                GlassIconButton(
                    systemName: rightIcon,
                    glassID: nil,                 // без морфинга → не уезжает, просто пропадает
                    namespace: namespace,
                    action: {}
                )
                .allowsHitTesting(false)
            } else {
                placeholder(width: 60)
            }
        }
        .frame(height: 60)
    }

    /// Прозрачная «дырка» размером с кнопку — держит раскладку, пока
    /// шестерёнка морфит в панель.
    private func placeholder(width: CGFloat) -> some View {
        Color.clear.frame(width: width, height: 60)
    }
}

// MARK: - Кнопка-иконка 60×60

/// Стеклянная кнопка 60×60 с белой SF-иконкой по центру (обёртка над GlassButton).
/// Используется и в верхнем, и в нижнем тулбаре.
struct GlassIconButton: View {

    let systemName: String
    let glassID: String?
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        GlassButton(shape: Circle(), glassID: glassID, namespace: namespace, action: action) {
            Image(systemName: systemName)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
        }
    }
}

// MARK: - Центральная капсула 180×60

/// Стеклянная капсула-кнопка 180×60 (обёртка над GlassButton).
private struct GlassCapsuleButton: View {

    let glassID: String?
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        GlassButton(
            shape: Capsule(),
            glassID: glassID,
            namespace: namespace,
            action: action,
            showDome: false  // Без сферы — только на круглых кнопках.
        ) {
            Text("Hello")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 180, height: 60)
        }
    }
}
