//
//  ContentView.swift
//  animations for metronome
//
//  Created by Ulad Luch on 23/06/2026.
//

import SwiftUI

struct ContentView: View {

    /// Namespace для GlassButton-обёрток.
    @Namespace private var glassNS

    /// Подсветка (свечение Path) вкл/выкл.
    @State private var glowOn = false

    var body: some View {
        ZStack(alignment: .top) {
            // Тёмная тема: основной фон полностью чёрный.
            Color.appBackground
                .ignoresSafeArea()

            // Цветной свет под стеклом (lensing).
            GlassBackdrop(glowOn: glowOn)

            // Верхний тулбар: шестерёнка + капсула + три точки.
            // Пока кнопки ничего не открывают (sheet вернём позже).
            GlassEffectContainer(spacing: 16) {
                TopToolbar(
                    namespace: glassNS,
                    onLeft: {},
                    onCenter: {},
                    onRight: {}
                )
                .containerRelativeFrame(.horizontal) { length, _ in length - 32 }
                .padding(.top, 8)
            }

            // Две кнопки по центру: обе включают/выключают подсветку (Path).
            VStack(spacing: 12) {
                // Стеклянная кнопка.
                GlassButton(
                    shape: Capsule(),
                    namespace: glassNS,
                    action: {
                        withAnimation(.easeInOut(duration: 0.35)) { glowOn.toggle() }
                    },
                    showDome: false
                ) {
                    Text(glowOn ? "Turn off glow" : "Turn on glow")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .frame(height: 50)
                }

                // Белая prominent-кнопка (тот же функционал), чёрный шрифт.
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.easeInOut(duration: 0.35)) { glowOn.toggle() }
                }) {
                    Text(glowOn ? "Turn off glow" : "Turn on glow")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 24)
                        .frame(height: 50)
                }
                .buttonStyle(.glassProminent)
                .tint(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .offset(y: 80)

            // Нижний тулбар — прижат к низу.
            BottomToolbar()
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 8)
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
