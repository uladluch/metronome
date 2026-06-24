//
//  TopToolbar.swift
//  animations for metronome
//
//  Верхний тулбар: слева — место под шестерёнку (её рисует и анимирует
//  ExpandableGlassMenu в ContentView), по центру — капсула, справа — три точки.
//  Когда шестерёнка разворачивается в панель, капсула и три точки угасают
//  (за это отвечает opacity в ContentView по morphProgress).
//

import SwiftUI

struct TopToolbar: View {

    let namespace: Namespace.ID

    let onCenter: () -> Void
    let onRight: () -> Void

    private let rightIcon = "ellipsis"

    var body: some View {
        HStack(spacing: 0) {
            // Место под шестерёнку — её рисует ExpandableGlassMenu (overlay).
            placeholder(width: 60)

            Spacer(minLength: 0)

            GlassCapsuleButton(
                glassID: nil,
                namespace: namespace,
                action: onCenter
            )

            Spacer(minLength: 0)

            GlassIconButton(
                systemName: rightIcon,
                glassID: nil,
                namespace: namespace,
                action: onRight
            )
        }
        .frame(height: 60)
    }

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
            showDome: false
        ) {
            Text("Hello")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 180, height: 60)
        }
    }
}
