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

    /// Значение «линейки» (tick-слайдер) под кнопками.
    @State private var tempo: Double = 120

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

            // Кнопки + «линейка» по центру.
            VStack(spacing: 28) {
                // Две кнопки: обе включают/выключают подсветку (Path).
                VStack(spacing: 12) {
                    // Тёмная стеклянная кнопка (кастомный GlassButton — плотнее, «чернее»).
                    GlassButton(
                        shape: Capsule(),
                        namespace: glassNS,
                        action: {
                            withAnimation(.easeInOut(duration: 0.35)) { glowOn.toggle() }
                        },
                        showDome: false,
                        // .clear прозрачное → нативный интерактив масштабирует только
                        // текст. pressScale тянет всю кнопку целиком, под уровень белой.
                        pressScale: 1.08
                    ) {
                        Text(glowOn ? "Turn off glow" : "Turn on glow")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }

                    // Белая кнопка (тот же функционал), чёрный шрифт.
                    // Стекло прямо на лейбле 50pt (как у чёрной) → ровно 50pt, не сдавлено.
                    // .regular.tint(.white) — белая заливка + интерактив.
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.easeInOut(duration: 0.35)) { glowOn.toggle() }
                    }) {
                        Text(glowOn ? "Turn off glow" : "Turn on glow")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .glassEffect(.regular.tint(.white).interactive(), in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .frame(width: 240)

                // Рулер с кнопками шага слева/справа (тот же GlassIconButton, 40×40).
                HStack(spacing: 10) {
                    GlassIconButton(
                        systemName: "minus",
                        glassID: nil,
                        namespace: glassNS,
                        size: 40,
                        iconSize: 18,
                        action: { tempo = max(tempo - 1, 40) }
                    )

                    TickSlider(value: $tempo)
                        .frame(width: 250, height: 44)

                    GlassIconButton(
                        systemName: "plus",
                        glassID: nil,
                        namespace: glassNS,
                        size: 40,
                        iconSize: 18,
                        action: { tempo = min(tempo + 1, 240) }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .offset(y: -60)  // чуть выше середины

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
