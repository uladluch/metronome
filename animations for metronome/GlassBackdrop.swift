//
//  GlassBackdrop.swift
//  animations for metronome
//
//  Мягкий цветной свет ПОД стеклом.
//
//  Liquid Glass преломляет и отражает то, что находится за ним. Именно из этого
//  на кромке стекла рождается «радужное» переливание — на чистом чёрном фоне его
//  взять неоткуда (преломлять нечего, виден только белый specular-край).
//
//  Слой приглушён и собран у верхней части экрана (под тулбаром и окнами),
//  поэтому общая тёмная тема сохраняется, а медленный дрейф пятен заставляет
//  переливание «жить».
//

import SwiftUI

struct GlassBackdrop: View {

    @State private var animate = false

    var body: some View {
        ZStack {
            orb(.blue,   size: 280, base: CGSize(width: -120, height: -20), drift: CGSize(width:  40, height:  30))
            orb(.purple, size: 260, base: CGSize(width:   10, height: -60), drift: CGSize(width: -35, height:  25))
            orb(.cyan,   size: 230, base: CGSize(width:  135, height: -10), drift: CGSize(width:  30, height: -28))
            orb(.pink,   size: 220, base: CGSize(width:   60, height:  70), drift: CGSize(width: -30, height: -22))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear { animate = true }
    }

    private func orb(_ color: Color, size: CGFloat, base: CGSize, drift: CGSize) -> some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .blur(radius: 80)
            .opacity(0.45)
            .offset(
                x: base.width + (animate ? drift.width : 0),
                y: base.height + (animate ? drift.height : 0)
            )
            .animation(.easeInOut(duration: 9).repeatForever(autoreverses: true), value: animate)
    }
}
