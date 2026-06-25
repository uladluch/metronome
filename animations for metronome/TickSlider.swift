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

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let cx = w / 2

            ZStack {
                // Тики (рисуем в Canvas, центр — текущее значение).
                Canvas { ctx, size in
                    let midY = size.height / 2
                    let tickH = size.height * 0.42
                    let half = Int(cx / tickSpacing) + 2
                    let base = value.rounded()

                    for i in -half...half {
                        let tickVal = base + Double(i)
                        guard tickVal >= range.lowerBound, tickVal <= range.upperBound else { continue }
                        let x = cx + CGFloat(tickVal - value) * tickSpacing

                        var p = Path()
                        p.move(to: CGPoint(x: x, y: midY - tickH / 2))
                        p.addLine(to: CGPoint(x: x, y: midY + tickH / 2))
                        ctx.stroke(p, with: .color(.white.opacity(0.55)), lineWidth: 2)
                    }
                }
                // Затухание к краям.
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .white, location: 0.5),
                            .init(color: .clear, location: 1)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

                // Яркий индикатор по центру.
                Capsule()
                    .fill(.white)
                    .frame(width: 6, height: h * 0.7)
                    .shadow(color: .white.opacity(0.6), radius: 8)
            }
            .frame(width: w, height: h)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { g in
                        if dragStart == nil { dragStart = value }
                        let start = dragStart ?? value
                        let newValue = start - Double(g.translation.width / tickSpacing)
                        value = min(max(newValue, range.lowerBound), range.upperBound)
                    }
                    .onEnded { _ in dragStart = nil }
            )
            // Лёгкий хаптик на каждом пройденном тике.
            .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.4),
                             trigger: Int(value))
        }
    }
}
