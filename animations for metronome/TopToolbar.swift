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

    /// Нажатие капсулы Hello — зум применяем снаружи, к её GlassEffectContainer.
    @State private var helloPressed = false

    var body: some View {
        HStack(spacing: 0) {
            // Шестерёнка (пока без действия). Свой контейнер — как у чёрной кнопки.
            GlassEffectContainer {
                GlassIconButton(
                    systemName: leftIcon,
                    glassID: nil,
                    namespace: namespace,
                    showShine: true,
                    action: onLeft
                )
            }

            Spacer(minLength: 0)

            // Капсула Hello — те же слои/эффекты, что у чёрной кнопки
            // (dome, переливание, компактный блик, горизонтальный зум),
            // только оригинального размера 180×60. Зум — снаружи контейнера.
            GlassEffectContainer {
                GlassCapsuleIconButton(
                    glassID: nil,
                    namespace: namespace,
                    size: .init(width: 180, height: 60),
                    pressScaleHorizontalOnly: true,
                    showShine: true,
                    shineImage: "Shine",
                    shineOpacity: 0.14,
                    shineWidthFactor: 0.5,
                    shineHeightFactor: 2.2,
                    externalPressScale: true,
                    onPressedChange: { pressed in
                        withAnimation(.easeOut(duration: pressed ? 0.12 : 0.3)) {
                            helloPressed = pressed
                        }
                    },
                    action: onCenter
                ) {
                    Text("Hello")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }
            .scaleEffect(x: helloPressed ? 1.08 : 1.0, y: 1.0)

            Spacer(minLength: 0)

            // Треугольник. Свой контейнер — как у чёрной кнопки.
            GlassEffectContainer {
                GlassIconButton(
                    systemName: rightIcon,
                    glassID: nil,
                    namespace: namespace,
                    showShine: true,
                    action: onRight
                )
            }
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
    var shineOpacity: Double = 0.04
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
            shineOpacity: shineOpacity,
            shineForcePressed: shineForcePressed
        ) {
            Image(systemName: systemName)
                .font(.system(size: iconSize, weight: .medium))
                .foregroundStyle(iconColor)
                .frame(width: size, height: size)
        }
    }
}

// MARK: - Обёртки над GlassButton для стандартных форм

/// Капсула с параметрами круглых кнопок (для чёрной кнопки в ContentView).
struct GlassCapsuleIconButton: View {

    let glassID: String?
    let namespace: Namespace.ID
    var size: CGSize = .init(width: 240, height: 50)
    var pressScale: CGFloat = 1.08
    var pressScaleHorizontalOnly: Bool = false
    var repeatAction: (() -> Void)? = nil
    var showShine: Bool = false
    var shineImage: String = "Shine"
    var shineOpacity: Double = 0.04
    var shineWidthFactor: CGFloat? = nil
    var shineHeightFactor: CGFloat? = nil
    var shineForcePressed: Bool = false
    var externalPressScale: Bool = false
    var onPressedChange: ((Bool) -> Void)? = nil
    let action: () -> Void
    @ViewBuilder let label: () -> any View

    var body: some View {
        GlassButton(
            shape: Capsule(),
            glassID: glassID,
            namespace: namespace,
            action: action,
            repeatAction: repeatAction,
            pressScale: pressScale,
            showShine: showShine,
            shineImage: shineImage,
            shineOpacity: shineOpacity,
            shineWidthFactor: shineWidthFactor,
            shineHeightFactor: shineHeightFactor,
            shineForcePressed: shineForcePressed,
            domeAsRadial: false,
            pressScaleHorizontalOnly: pressScaleHorizontalOnly,
            externalPressScale: externalPressScale,
            onPressedChange: onPressedChange
        ) {
            // Явная фиксированная ширина — чтобы пивот зума был точно по центру
            // (с maxWidth:.infinity внутри контейнера центр «уплывал» вправо).
            AnyView(label())
                .frame(width: size.width, height: size.height)
        }
    }
}

