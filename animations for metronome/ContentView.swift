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
    /// Яркость свечения: 0.5 — приглушено (выкл), 1 — ярко (вкл). Мигает при glowOn.
    @State private var glowLevel: Double = 0.5

    /// Значение «линейки» (tick-слайдер) под кнопками.
    @State private var tempo: Double = 120

    /// Видны ли кнопки +/- (по умолчанию скрыты, появляются при взаимодействии).
    @State private var controlsVisible = false
    @State private var hideTask: Task<Void, Never>?

    var body: some View {
        ZStack(alignment: .top) {
            // Тёмная тема: основной фон полностью чёрный.
            Color.appBackground
                .ignoresSafeArea()

            // Цветной свет под стеклом (lensing). Яркость = glowLevel (мигает).
            GlassBackdrop(level: glowLevel)

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

            // Бобы (сверху) + рулер + кнопки. Всё опущено ниже.
            VStack(spacing: 36) {
                // Новый контрол — светящиеся бобы.
                BobsControl()

                VStack(spacing: 24) {
                    // Рулер с широкими тап-зонами слева/справа (теперь СВЕРХУ).
                    HStack(spacing: 0) {
                        StepZone(
                            systemName: "minus",
                            namespace: glassNS,
                            alignment: .trailing,
                            visible: controlsVisible,
                            onShow: showControls,
                            onStep: { step(-1) },
                            onHide: scheduleHide
                        )

                        TickSlider(value: $tempo, onInteractingChange: { interacting in
                            if interacting { showControls() } else { scheduleHide() }
                        })
                        .frame(width: 230, height: 100)  // выше — зона свайпа больше

                        StepZone(
                            systemName: "plus",
                            namespace: glassNS,
                            alignment: .leading,
                            visible: controlsVisible,
                            onShow: showControls,
                            onStep: { step(1) },
                            onHide: scheduleHide
                        )
                    }

                    // Две кнопки glow (теперь СНИЗУ).
                    VStack(spacing: 12) {
                        // Тёмная стеклянная кнопка (кастомный GlassButton — плотнее, «чернее»).
                        GlassButton(
                            shape: Capsule(),
                            namespace: glassNS,
                            action: { toggleGlow() },
                            showDome: false,
                            pressScale: 1.08
                        ) {
                            Text(glowOn ? "Turn off glow" : "Turn on glow")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        }

                        // Белая кнопка (тот же функционал), чёрный шрифт.
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            toggleGlow()
                        }) {
                            Text(glowOn ? "Turn off glow" : "Turn on glow")
                                .font(.headline)
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .glassEffect(.regular.tint(.white).interactive(), in: Capsule())
                                .contentShape(Capsule())  // тапается вся кнопка
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(width: 240)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .offset(y: 30)  // опущено ниже

            // Нижний тулбар — прижат к низу.
            BottomToolbar()
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 8)
        }
        // Клавиатура из BPM-шита не должна двигать контент под ним (иначе кнопки
        // и рулер прыгают при разворачивании/сворачивании шита).
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    // MARK: - Шаг рулера и видимость кнопок +/-

    /// Вкл/выкл подсветку. Включённая — МИГАЕТ с темпом 90 bpm
    /// (загорание как «вкл», затухание как «выкл», бесконечный autoreverse).
    private func toggleGlow() {
        glowOn.toggle()
        if glowOn {
            let beat = 60.0 / 90.0  // длительность одного удара (90 bpm)
            withAnimation(.easeInOut(duration: beat / 2).repeatForever(autoreverses: true)) {
                glowLevel = 1.0
            }
        } else {
            withAnimation(.easeInOut(duration: 0.35)) { glowLevel = 0.5 }
        }
    }

    /// Шаг на ±1 (clamp 40...240) + держим кнопки видимыми.
    private func step(_ delta: Double) {
        tempo = min(max(tempo + delta, 40), 240)
        showControls()
        scheduleHide()
    }

    /// Быстро показать кнопки.
    private func showControls() {
        hideTask?.cancel()
        withAnimation(.easeOut(duration: 0.12)) { controlsVisible = true }
    }

    /// Спрятать кнопки: через 1.5 секунды бездействия — плавное затухание (300ms).
    private func scheduleHide() {
        hideTask?.cancel()
        hideTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(1500))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.3)) { controlsVisible = false }
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
