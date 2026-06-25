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

    /// Видны ли кнопки +/- (по умолчанию скрыты, появляются при взаимодействии).
    @State private var controlsVisible = false
    @State private var hideTask: Task<Void, Never>?

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
            VStack(spacing: 24) {
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

                // Рулер с широкими тап-зонами слева/справа. Кнопки 44×44 скрыты по
                // умолчанию; тап в зоне (даже мимо кнопки) показывает их и делает шаг.
                HStack(spacing: 0) {
                    stepZone(systemName: "minus", delta: -1, buttonAlignment: .trailing)

                    TickSlider(value: $tempo, onInteractingChange: { interacting in
                        if interacting { showControls() } else { scheduleHide() }
                    })
                    .frame(width: 230, height: 100)  // выше — зона свайпа больше

                    stepZone(systemName: "plus", delta: 1, buttonAlignment: .leading)
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

    // MARK: - Шаг рулера и видимость кнопок +/-

    /// Шаг на ±1 (clamp 40...240) + держим кнопки видимыми.
    private func step(_ delta: Double) {
        tempo = min(max(tempo + delta, 40), 240)
        showControls()
        scheduleHide()
    }

    /// Широкая тап-зона сбоку от рулера: тап в любом месте зоны (даже мимо кнопки)
    /// показывает кнопку и делает шаг. Кнопка 44×44 прижата к рулеру (alignment).
    @ViewBuilder
    private func stepZone(systemName: String, delta: Double, buttonAlignment: Alignment) -> some View {
        ZStack(alignment: buttonAlignment) {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { step(delta) }

            GlassIconButton(
                systemName: systemName,
                glassID: nil,
                namespace: glassNS,
                size: 44,
                iconSize: 20,
                repeatAction: { step(delta) },
                action: { step(delta) }
            )
            .opacity(controlsVisible ? 1 : 0)
        }
        .frame(width: 56, height: 100)
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
