//
//  StepZone.swift
//  animations for metronome
//
//  Широкая тап-зона сбоку от рулера. Один жест на всю зону (без конфликта с
//  кнопкой) → тап срабатывает с первого раза. Кнопка ВСЕГДА в дереве (только
//  opacity), проявляется под пальцем на касании. Тап = шаг; зажать = авто-повтор.
//

import SwiftUI

struct StepZone: View {

    let systemName: String
    let namespace: Namespace.ID
    let alignment: Alignment
    /// Видимость кнопки (общая с рулером).
    var visible: Bool

    let onShow: () -> Void   // касание началось — показать
    let onStep: () -> Void   // один шаг
    let onHide: () -> Void   // отпустили — запланировать скрытие

    @State private var pressing = false
    @State private var repeatTimer: Timer?
    @State private var didRepeat = false
    @State private var repeatCount = 0

    var body: some View {
        ZStack(alignment: alignment) {
            Color.clear

            // Кнопка — только визуал (жесты на зоне). Проявляется под пальцем.
            GlassIconButton(
                systemName: systemName,
                glassID: nil,
                namespace: namespace,
                size: 44,
                iconSize: 20,
                action: {}
            )
            .allowsHitTesting(false)
            .opacity(visible ? 1 : 0)
            .scaleEffect(pressing ? 1.1 : 1.0)
            .animation(.easeOut(duration: 0.15), value: pressing)
        }
        .frame(width: 56, height: 100)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !pressing {
                        pressing = true
                        onShow()          // проявить под пальцем
                        startRepeat()
                    }
                }
                .onEnded { _ in
                    pressing = false
                    stopRepeat()
                    if !didRepeat { onStep() }  // обычный тап — один шаг
                    didRepeat = false
                    onHide()
                }
        )
    }

    private func startRepeat() {
        didRepeat = false
        repeatCount = 0
        repeatTimer?.invalidate()
        // Пауза перед авто-повтором (чтобы обычный тап не триггерил), потом — ускорение.
        repeatTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { _ in
            didRepeat = true
            fireRepeat()
        }
    }

    /// Один шаг авто-повтора + перепланирование с УМЕНЬШАЮЩИМСЯ интервалом
    /// (чем дольше держишь — тем быстрее листает; хэптик ускоряется вместе со сменой значения).
    private func fireRepeat() {
        onStep()
        repeatCount += 1
        let interval = max(0.025, 0.16 - Double(repeatCount) * 0.012)  // от ~0.15 до 0.025
        repeatTimer?.invalidate()
        repeatTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
            fireRepeat()
        }
    }

    private func stopRepeat() {
        repeatTimer?.invalidate()
        repeatTimer = nil
        repeatCount = 0
    }
}
