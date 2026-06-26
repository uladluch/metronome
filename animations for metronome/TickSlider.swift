//
//  TickSlider.swift
//  animations for metronome
//
//  «Линейка» (ruler slider): горизонтальная шкала из тиков, которые затухают к
//  краям, и яркий индикатор по центру. Тянется драгом — тики проезжают под
//  фиксированным центром, значение меняется. Лёгкий хаптик на каждом тике.
//

import SwiftUI

struct TickSlider: View {

    @Binding var value: Double
    var range: ClosedRange<Double> = 40...240
    /// Сообщает наружу: true — начали тянуть, false — отпустили.
    var onInteractingChange: (Bool) -> Void = { _ in }

    /// Расстояние между тиками в точках.
    private let tickSpacing: CGFloat = 11
    /// Чувствительность драга/инерции (<1 — медленнее, мягче реакция).
    private let dragSensitivity: Double = 0.8

    @State private var dragStart: Double?
    /// Непрерывная визуальная позиция (для плавного скролла). value = округление.
    @State private var displayValue: Double = 0
    /// Масштаб центральной черточки (растёт со скоростью инерции).
    @State private var indicatorScale: CGFloat = 1.0
    /// Инерция (momentum) после резкого броска.
    @State private var momentumTimer: Timer?
    @State private var momentumVelocity: Double = 0

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height          // высота TOUCH-зоны (скролл)
            let cx = w / 2

            // Визуал (тики + индикатор) фиксированной высоты, по центру touch-зоны.
            let contentH: CGFloat = 40
            let midY = h / 2
            let baseline = midY + contentH / 2        // нижняя линия тиков
            let indicatorH = contentH * 0.8
            // Низ индикатора чуть НИЖЕ тиков (+4), чтобы прикрыть тики под собой.
            let indicatorOffset = contentH / 2 - indicatorH / 2 + 4

            ZStack {
                // Тики: ярко у центра (будто индикатор светит), жёсткий спад к краям.
                // Скроллятся ПЛАВНО по displayValue. Каждый 5-й — мажорный (выше/толще),
                // чтобы было видно движение и направление.
                Canvas { ctx, size in
                    let minorH = contentH * 0.38
                    let majorH = contentH * 0.55
                    let half = Int(cx / tickSpacing) + 2
                    let base = displayValue.rounded()
                    let maxDist = cx * 0.85  // за этим — полностью погасли (жёстко)

                    // За пределами диапазона тики рисуем тоже (чтобы не было чёрной
                    // пустоты на краях), но почти прозрачными — как задизейбленные.
                    let outOfRangeOpacity = 0.15

                    for i in -half...half {
                        let tickVal = base + Double(i)
                        let x = cx + CGFloat(tickVal - displayValue) * tickSpacing

                        let norm = min(abs(x - cx) / maxDist, 1)
                        let brightness = pow(Double(1 - norm), 2.6)  // жёсткое затухание

                        let inRange = tickVal >= range.lowerBound && tickVal <= range.upperBound
                        let opacity: Double
                        if inRange {
                            opacity = brightness
                        } else {
                            // Задизейбленные тики за упором: ровная блёклая видимость
                            // на всю ширину (без прожекторного провала), гаснут только
                            // в самых крайних ~25pt у края экрана, чтобы не обрезались.
                            let edgeDist = Double(cx) - Double(abs(x - cx))
                            let edgeFade = min(edgeDist / 25.0, 1)
                            opacity = outOfRangeOpacity * edgeFade
                        }

                        let isMajor = Int(tickVal) % 5 == 0
                        let tickH = isMajor ? majorH : minorH

                        var p = Path()
                        p.move(to: CGPoint(x: x, y: baseline - tickH))
                        p.addLine(to: CGPoint(x: x, y: baseline))
                        // Скруглённые концы у черточек.
                        ctx.stroke(p, with: .color(.white.opacity(opacity)),
                                   style: StrokeStyle(lineWidth: isMajor ? 2.5 : 2, lineCap: .round))
                    }
                }

                // Яркий центральный индикатор. Растёт со скоростью прокрутки
                // (drag/инерция), уменьшается по замедлению. Низ чуть ниже тиков.
                Capsule()
                    .fill(.white)
                    .frame(width: 6, height: indicatorH)
                    .shadow(color: .white.opacity(0.85), radius: 12 + (indicatorScale - 1) * 34)
                    .scaleEffect(indicatorScale, anchor: .bottom)
                    .offset(y: indicatorOffset)
            }
            .frame(width: w, height: h)
            .contentShape(Rectangle())
            .onAppear { displayValue = value }
            // Внешние изменения (кнопки +/-) — снаппи доезжаем. Не вмешиваемся во
            // время драга и инерции.
            .onChange(of: value) { _, newValue in
                if dragStart == nil && momentumTimer == nil {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.85)) {
                        displayValue = newValue
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { g in
                        stopMomentum()
                        if dragStart == nil {
                            dragStart = displayValue
                            onInteractingChange(true)
                            withAnimation(.easeOut(duration: 0.25)) { indicatorScale = 1.15 }
                        }
                        let start = dragStart ?? displayValue
                        // dragSensitivity < 1 — рулер реагирует медленнее (не дёргано).
                        let raw = start - Double(g.translation.width / tickSpacing) * dragSensitivity
                        displayValue = min(max(raw, range.lowerBound), range.upperBound)
                        value = displayValue.rounded()
                    }
                    .onEnded { g in
                        dragStart = nil
                        onInteractingChange(false)
                        // Импульс по скорости броска (ticks/sec). Драг вправо уменьшает значение.
                        let v = max(-250, min(250, -Double(g.velocity.width) / Double(tickSpacing) * dragSensitivity))
                        if abs(v) > 3 {
                            startMomentum(v)
                        } else {
                            snapAndRest()
                        }
                    }
            )
            // Чёткий хаптик на каждом пройденном тике.
            .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.8),
                             trigger: Int(displayValue))
        }
    }

    // MARK: - Инерция (momentum)

    private func startMomentum(_ v0: Double) {
        momentumVelocity = v0
        momentumTimer?.invalidate()
        momentumTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
            tickMomentum()
        }
    }

    private func tickMomentum() {
        let dt = 1.0 / 60.0
        var v = momentumVelocity
        var next = displayValue + v * dt
        if next <= range.lowerBound { next = range.lowerBound; v = 0 }
        else if next >= range.upperBound { next = range.upperBound; v = 0 }
        displayValue = next
        value = displayValue.rounded()

        v *= 0.95  // трение
        momentumVelocity = v

        // Центральная черточка растёт со скоростью — но плавно (лерп к цели),
        // чтобы не подскакивала.
        let speed = min(abs(v) / 80.0, 1.0)
        let targetScale = 1.0 + CGFloat(speed) * 0.4
        indicatorScale += (targetScale - indicatorScale) * 0.2

        if abs(v) < 1.5 {
            stopMomentum()
            snapAndRest()
        }
    }

    private func stopMomentum() {
        momentumTimer?.invalidate()
        momentumTimer = nil
    }

    /// Доезд до ближайшей черточки + плавное уменьшение черточки.
    private func snapAndRest() {
        value = min(max(displayValue.rounded(), range.lowerBound), range.upperBound)
        withAnimation(.easeOut(duration: 0.45)) { indicatorScale = 1.0 }
    }
}
