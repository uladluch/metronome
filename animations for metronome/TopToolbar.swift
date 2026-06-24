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
                .allowsHitTesting(false)
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

/// Стеклянная кнопка 60×60 с белой SF-иконкой по центру.
///
/// Без обёртки `Button`: касание получает само `.interactive()`-стекло —
/// иначе кнопка перехватывала бы тап, и не было бы ни нативного свечения
/// на нажатии, ни корректного зацепления морфинга через glassEffectID.
private struct GlassIconButton: View {

    let systemName: String
    let glassID: String?
    let namespace: Namespace.ID
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 22, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: 60, height: 60)
            .appGlass(in: .circle, interactive: true)
            // Inner shadow (Figma): белый сверху, мягкий. Ручной (stroke+blur+mask)
            // рисуется надёжнее, чем .clear.shadow(.inner) на прозрачной заливке.
            .overlay {
                Circle()
                    .stroke(Color.white.opacity(0.35), lineWidth: 8)
                    .blur(radius: 12)
                    .offset(y: 4)
                    .mask(Circle())
            }
            // Свечение по нажатию — поверх нативного, чтобы было заметно.
            .overlay {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white.opacity(0.55), .white.opacity(0)],
                            center: .center, startRadius: 0, endRadius: 36
                        )
                    )
                    .opacity(isPressed ? 1 : 0)
            }
            .glassMorphID(glassID, in: namespace)
            .contentShape(Circle())
            .onTapGesture(perform: action)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed { withAnimation(.easeOut(duration: 0.12)) { isPressed = true } }
                    }
                    .onEnded { _ in
                        withAnimation(.easeOut(duration: 0.3)) { isPressed = false }
                    }
            )
            .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Центральная капсула 180×60

/// Стеклянная капсула-кнопка 180×60.
private struct GlassCapsuleButton: View {

    let glassID: String?
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        Color.clear
            .frame(width: 180, height: 60)
            .appGlass(in: .capsule, interactive: true)
            .glassMorphID(glassID, in: namespace)
            .contentShape(Capsule())
            .onTapGesture(perform: action)
            .accessibilityAddTraits(.isButton)
    }
}
