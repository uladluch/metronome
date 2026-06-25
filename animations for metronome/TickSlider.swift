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
    private let tickSpacing: CGFloat = 14

    @State private var dragStart: Double?
    /// Идёт ли взаимодействие — центральный индикатор слегка растёт.
    @State private var active = false

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let cx = w / 2

            ZStack {
                // Тики. Яркость считаем по-тиково: ярко у центра (будто индикатор
                // на них светит), жёсткий спад к краям.
                Canvas { ctx, size in
                    let midY = size.height / 2
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
                        p.move(to: CGPoint(x: x, y: midY - tickH / 2))
                        p.addLine(to: CGPoint(x: x, y: midY + tickH / 2))
                        ctx.stroke(p, with: .color(.white.opacity(brightness)), lineWidth: 2)
                    }
                }

                // Яркий центральный индикатор — медленно чуть растёт при свайпе.
                Capsule()
                    .fill(.white)
                    .frame(width: 6, height: h * 0.7)
                    .shadow(color: .white.opacity(0.7), radius: active ? 12 : 7)
                    .scaleEffect(active ? 1.22 : 1.0)
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
                        let newValue = start - Double(g.translation.width / tickSpacing)
                        value = min(max(newValue, range.lowerBound), range.upperBound)
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
