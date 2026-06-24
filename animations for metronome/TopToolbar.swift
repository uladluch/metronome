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
    let activePanel: PanelPosition?
    let morphProgress: CGFloat

    let onLeft: () -> Void
    let onCenter: () -> Void
    let onRight: () -> Void

    private let leftIcon = "gearshape"
    private let rightIcon = "ellipsis"

    var body: some View {
        HStack(spacing: 0) {
            // Морфинг левой кнопки (шестерёнки): начинается при morphProgress > 0.
            // Stage 1 (progress 0→0.5): растяжение вниз (scaleY, cornerRadius).
            // Stage 2 (progress 0.5→1): раскрытие панели.
            if morphProgress < 1 {
                MorphableGlassButton(
                    systemName: leftIcon,
                    glassID: PanelPosition.left.glassID,
                    namespace: namespace,
                    morphProgress: morphProgress,
                    isActive: activePanel == .left,
                    action: onLeft
                )
            } else {
                placeholder(width: 60)
            }

            Spacer(minLength: 0)

            // Центральная капсула: скрывается при morphProgress > 0.
            if morphProgress == 0 {
                GlassCapsuleButton(
                    glassID: nil,
                    namespace: namespace,
                    action: onCenter
                )
            } else {
                placeholder(width: 180)
            }

            Spacer(minLength: 0)

            // Правая кнопка: скрывается при morphProgress > 0.
            if morphProgress == 0 {
                GlassIconButton(
                    systemName: rightIcon,
                    glassID: nil,
                    namespace: namespace,
                    action: onRight
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

// MARK: - Морфирующая кнопка-иконка

/// Стеклянная кнопка-иконка, которая морфирует из 60×60 в овал и далее в полную панель.
/// Stage 1 (progress 0→0.5): растяжение вниз (scaleY растёт, cornerRadius уменьшается от 30 к 0 = овал).
/// Stage 2 (progress 0.5→1): панель раскрывается из овала.
struct MorphableGlassButton: View {

    let systemName: String
    let glassID: String
    let namespace: Namespace.ID
    let morphProgress: CGFloat
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        // Stage 1: progress 0→0.5 — растяжение в овал.
        // Stage 2: progress 0.5→1 — раскрытие панели (opacity = 0 при progress > 0.5).

        let stage1Progress = min(morphProgress * 2, 1.0)  // Нормализуем 0→0.5 в 0→1
        let stage2Progress = max((morphProgress - 0.5) * 2, 0)  // Нормализуем 0.5→1 в 0→1

        // Высота: 60 + stage1Progress * (растяжение вниз на экран).
        // При progress = 0.5, высота должна быть достаточной для раскрытия.
        let stretchHeight = 60 + (stage1Progress * 200)

        // cornerRadius: 30 (круг) → 0 (овал) к концу stage 1.
        let cornerRadius = 30 - (stage1Progress * 30)

        // Opacity для кнопки: 1 в stage 1, 0 в stage 2.
        let buttonOpacity = 1 - stage2Progress

        return GlassButton(
            shape: RoundedRectangle(cornerRadius: max(0, cornerRadius)),
            glassID: glassID,
            namespace: namespace,
            action: action,
            showDome: stage1Progress < 1
        ) {
            Image(systemName: systemName)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(.white)
                .frame(height: max(60, stretchHeight))
                .frame(maxWidth: .infinity)
        }
        .frame(width: 60, height: max(60, stretchHeight))
        .opacity(buttonOpacity)
        .animation(.spring(response: 0.55, dampingFraction: 0.78), value: morphProgress)
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
