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

    /// Базовый материал Liquid Glass.
    /// `.clear` — почти прозрачное стекло: не заливает контент блюром, а
    /// преломляет свет по кромке (lensing по периметру). Радужное переливание
    /// даёт цветной слой под стеклом (см. GlassBackdrop). `.regular` — наоборот,
    /// плотное матовое стекло.
    static let style: Glass = .clear
}

extension View {

    /// Применяет единый Liquid Glass приложения в заданной форме.
    ///
    /// - Parameters:
    ///   - shape: форма стекла (по умолчанию — капсула).
    ///   - interactive: включает «живой» отклик стекла на нажатие (для кнопок).
    func appGlass(in shape: some Shape = .capsule, interactive: Bool = false) -> some View {
        glassEffect(interactive ? AppGlass.style.interactive() : AppGlass.style, in: shape)
    }
}

// MARK: - Цвета

extension Color {

    /// Основной фон приложения — полностью чёрный (тёмная тема).
    static let appBackground = Color.black
}
