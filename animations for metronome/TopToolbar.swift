//
//  TopToolbar.swift
//  animations for metronome
//
//  Верхний тулбар: слева — шестерёнка, по центру — капсула, справа — три точки.
//  Кнопки пока без действий (sheet вернём позже).
//

import SwiftUI

struct TopToolbar: View {

    let namespace: Namespace.ID

    let onLeft: () -> Void
    let onCenter: () -> Void
    let onRight: () -> Void

    private let leftIcon = "circle"
    private let rightIcon = "triangle"

    var body: some View {
        HStack(spacing: 0) {
            // Шестерёнка (пока без действия).
            GlassIconButton(
                systemName: leftIcon,
                glassID: nil,
                namespace: namespace,
                showShine: true,
                action: onLeft
            )

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
                showShine: true,
                action: onRight
            )
        }
        .frame(height: 60)
    }
}

// MARK: - Кнопка-иконка 60×60

/// Стеклянная кнопка 60×60 с белой SF-иконкой по центру (обёртка над GlassButton).
/// Используется и в верхнем, и в нижнем тулбаре.
struct GlassIconButton: View {

    let systemName: String
    let glassID: String?
    let namespace: Namespace.ID
    var size: CGFloat = 60
    var iconSize: CGFloat = 22
    var iconColor: Color = .white
    var repeatAction: (() -> Void)? = nil
    var showShine: Bool = false
    var shineForcePressed: Bool = false
    let action: () -> Void

    var body: some View {
        GlassButton(
            shape: Circle(),
            glassID: glassID,
            namespace: namespace,
            action: action,
            repeatAction: repeatAction,
            showShine: showShine,
            shineForcePressed: shineForcePressed
        ) {
            Image(systemName: systemName)
                .font(.system(size: iconSize, weight: .medium))
                .foregroundStyle(iconColor)
                .frame(width: size, height: size)
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
            showDome: false,
            showShine: true,
            shineImage: "shine 2",
            shineOpacity: 0.2,
            shineHorizontalOnly: true,
            shineWidthFactor: 1.6,
            shineHeightFactor: 3
        ) {
            Text("Hello")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 180, height: 60)
        }
    }
}
