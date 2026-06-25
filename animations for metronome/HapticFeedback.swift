//
//  HapticFeedback.swift
//  animations for metronome
//
//  Вспомогательный модуль для тактильной обратной связи (haptic feedback).
//

import SwiftUI

extension View {
    /// Добавляет лёгкий тактильный импульс на тап.
    func hapticTap() -> some View {
        self.sensoryFeedback(.impact(flexibility: .soft), trigger: true)
    }

    /// Добавляет успешный тактильный сигнал (более заметный).
    func hapticSuccess() -> some View {
        self.sensoryFeedback(.success, trigger: true)
    }

    /// Добавляет тактильный сигнал при изменении значения (Slider, Picker).
    func hapticSelection() -> some View {
        self.sensoryFeedback(.selection, trigger: true)
    }
}
