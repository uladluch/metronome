//
//  AppTheme.swift
//  animations for metronome
//
//  Единая тема приложения: цвета и параметры Liquid Glass.
//  Здесь — единственный источник правды по стеклу: меняешь тут — меняется везде.
//

import SwiftUI

// MARK: - Liquid Glass

/// Единый параметр Liquid Glass для всего приложения.
///
/// Главное правило проекта: стекло настраивается в одном месте.
/// Хочешь сменить вид стекла во всём приложении — правишь только `AppGlass.style`.
enum AppGlass {

    /// Базовый материал Liquid Glass. Сейчас — «clear» (максимально прозрачный вариант).
    /// Поменяй на `.regular`, если нужно более плотное стекло.
    static let style: Glass = .clear

    /// Фоновый цвет для glass материала: 1F1F1F с прозрачностью 30%.
    static let backgroundColor = Color(red: 0x1F / 255, green: 0x1F / 255, blue: 0x1F / 255)
        .opacity(0.3)
}

// MARK: - Inner Shadow

/// Параметры inner shadow для glass material.
struct GlassInnerShadow {
    let color: Color = Color.white
    let opacity: Double = 0.08
    let offsetY: CGFloat = -4
    let blurRadius: CGFloat = 12
}

extension View {

    /// Применяет единый Liquid Glass приложения в заданной форме.
    /// Автоматически добавляет inner shadow (белый, прозрачность 0.08, смещение y = -4).
    ///
    /// - Parameters:
    ///   - shape: форма стекла (по умолчанию — капсула).
    ///   - interactive: включает «живой» отклик стекла на нажатие (для кнопок).
    func appGlass(in shape: some Shape = .capsule, interactive: Bool = false) -> some View {
        glassEffect(interactive ? AppGlass.style.interactive() : AppGlass.style, in: shape)
            .appGlassInnerShadow()
    }

    /// Добавляет inner shadow к glass-элементу.
    /// Параметры: белый (#FFFFFF) с opacity 0.08, смещение по Y = -4, blur = 12.
    private func appGlassInnerShadow() -> some View {
        let params = GlassInnerShadow()
        return self
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        params.color.opacity(params.opacity),
                        Color.clear
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .offset(y: params.offsetY / 2)
                .blur(radius: params.blurRadius)
            )
    }
}

// MARK: - Цвета

extension Color {

    /// Основной фон приложения — полностью чёрный (тёмная тема).
    static let appBackground = Color.black
}
