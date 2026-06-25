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

    @State private var dragStart: Double?
    /// Идёт ли взаимодействие — центральный индикатор слегка растёт.
    @State private var active = false
    /// Непрерывная визуальная позиция (для плавного скролла). value = округление.
    @State private var displayValue: Double = 0

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

                    for i in -half...half {
                        let tickVal = base + Double(i)
                        guard tickVal >= range.lowerBound, tickVal <= range.upperBound else { continue }
                        let x = cx + CGFloat(tickVal - displayValue) * tickSpacing

                        let norm = min(abs(x - cx) / maxDist, 1)
                        let brightness = pow(Double(1 - norm), 2.6)  // жёсткое затухание

                        let isMajor = Int(tickVal) % 5 == 0
                        let tickH = isMajor ? majorH : minorH

                        var p = Path()
                        p.move(to: CGPoint(x: x, y: baseline - tickH))
                        p.addLine(to: CGPoint(x: x, y: baseline))
                        // Скруглённые концы у черточек.
                        ctx.stroke(p, with: .color(.white.opacity(brightness)),
                                   style: StrokeStyle(lineWidth: isMajor ? 2.5 : 2, lineCap: .round))
                    }
                }

                // Яркий центральный индикатор — медленно чуть растёт при свайпе.
                // Низ чуть ниже тиков (прикрывает их), растёт вверх.
                Capsule()
                    .fill(.white)
                    .frame(width: 6, height: indicatorH)
                    .shadow(color: .white.opacity(0.7), radius: active ? 12 : 7)
                    .scaleEffect(active ? 1.22 : 1.0, anchor: .bottom)
                    .offset(y: indicatorOffset)
                    .animation(.easeInOut(duration: 0.6), value: active)
            }
            .frame(width: w, height: h)
            .contentShape(Rectangle())
            .onAppear { displayValue = value }
            // Внешние изменения (кнопки +/-) — плавно доезжаем до значения.
            .onChange(of: value) { _, newValue in
                if dragStart == nil {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        displayValue = newValue
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { g in
                        if dragStart == nil {
                            dragStart = displayValue
                            onInteractingChange(true)
                        }
                        active = true
                        let start = dragStart ?? displayValue
                        let raw = start - Double(g.translation.width / tickSpacing)
                        displayValue = min(max(raw, range.lowerBound), range.upperBound)
                        value = displayValue.rounded()
                    }
                    .onEnded { _ in
                        dragStart = nil
                        active = false
                        onInteractingChange(false)
                        // Снап: меняем value → onChange плавно доводит displayValue до черточки.
                        value = min(max(displayValue.rounded(), range.lowerBound), range.upperBound)
                    }
            )
            // Чёткий хаптик на каждом пройденном тике.
            .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.8),
                             trigger: Int(displayValue))
        }
    }
}
