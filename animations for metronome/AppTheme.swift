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
    /// Доступные методы: .tint(), .interactive(). Для fade-эффекта используется
    /// ручная сфера в GlassButton.
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

    /// Навешивает glassEffectID только если id задан.
    /// nil — стекло рисуется, но без морфинга (и без «уезжания» при удалении).
    /// Важно: это НЕ то же, что `glassEffectID(nil)` — тот гасит стекло.
    @ViewBuilder
    func glassMorphID(_ id: String?, in namespace: Namespace.ID) -> some View {
        if let id {
            glassEffectID(id, in: namespace)
        } else {
            self
        }
    }
}

// MARK: - Цвета

extension Color {

    /// Основной фон приложения — полностью чёрный (тёмная тема).
    static let backgroundPrimary = Color.black

    /// Вторичный фон (карточки, блоки) — #1C1C1C.
    static let backgroundSecondary = Color(red: 0x1C / 255, green: 0x1C / 255, blue: 0x1C / 255)

    /// Псевдоним основного фона (исторический) — равен backgroundPrimary.
    static let appBackground = backgroundPrimary

    /// Акцент контролов (слайдер, тоггл) — #737373.
    static let controlAccent = Color(red: 0x73 / 255, green: 0x73 / 255, blue: 0x73 / 255)
}
