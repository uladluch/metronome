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

    /// Расстояние между тиками в точках.
    private let tickSpacing: CGFloat = 11

    @State private var dragStart: Double?
    /// Идёт ли взаимодействие — центральный индикатор слегка растёт.
    @State private var active = false

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let cx = w / 2

            // Общая нижняя линия для тиков и центральной черточки.
            let baseline = h - 4
            let indicatorH = h * 0.7
            // Смещение капсулы вниз, чтобы её низ совпал с baseline.
            let indicatorOffset = baseline - indicatorH / 2 - h / 2

            ZStack {
                // Тики: ярко у центра (будто индикатор светит), жёсткий спад к краям.
                // Выровнены по нижней линии (baseline), короче центральной черточки.
                Canvas { ctx, size in
                    let tickH = size.height * 0.42
                    let half = Int(cx / tickSpacing) + 2
                    let base = value.rounded()
                    let maxDist = cx * 0.85  // за этим — полностью погасли (жёстко)

                    for i in -half...half {
                        let tickVal = base + Double(i)
                        guard tickVal >= range.lowerBound, tickVal <= range.upperBound else { continue }
                        let x = cx + CGFloat(tickVal - value) * tickSpacing

                        let norm = min(abs(x - cx) / maxDist, 1)
                        let brightness = pow(Double(1 - norm), 2.6)  // жёсткое затухание

                        var p = Path()
                        p.move(to: CGPoint(x: x, y: baseline - tickH))
                        p.addLine(to: CGPoint(x: x, y: baseline))
                        ctx.stroke(p, with: .color(.white.opacity(brightness)), lineWidth: 2)
                    }
                }

                // Яркий центральный индикатор — медленно чуть растёт при свайпе
                // (вверх от нижней линии), низ совпадает с тиками.
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
            .gesture(
                DragGesture()
                    .onChanged { g in
                        if dragStart == nil { dragStart = value }
                        active = true
                        let start = dragStart ?? value
                        let raw = start - Double(g.translation.width / tickSpacing)
                        // Снап на черточку — линейка прыгает тик-в-тик.
                        value = min(max(raw.rounded(), range.lowerBound), range.upperBound)
                    }
                    .onEnded { _ in
                        dragStart = nil
                        active = false
                    }
            )
            // Чёткий хаптик на каждом пройденном тике (заметнее).
            .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.8),
                             trigger: Int(value))
        }
    }
}
