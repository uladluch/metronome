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
    /// Яркость свечения: 0.5 — приглушено (выкл), 1 — ярко (вкл). Вспыхивает на удар.
    @State private var glowLevel: Double = 0.5
    /// Счётчик ударов. activeIndex боба = beatIndex % 4.
    @State private var beatIndex = 0
    /// Таймер метронома (бьётся, пока glowOn). Единый источник синхронизации.
    @State private var beatTimer: Timer?
    /// Темп визуального метронома.
    private let bpm: Double = 90
    private var beatInterval: Double { 60.0 / bpm }

    /// Отслеживание прессинга на кнопки для переливающегося эффекта стекла.
    @State private var darkButtonPressed = false
    @State private var whiteButtonPressed = false

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

            // Верхний тулбар + бобы наверху. Между капсулой и бобами — 40pt.
            VStack(spacing: 40) {
                // Тулбар: шестерёнка + капсула + три точки.
                GlassEffectContainer(spacing: 16) {
                    TopToolbar(
                        namespace: glassNS,
                        onLeft: {},
                        onCenter: {},
                        onRight: {}
                    )
                    .containerRelativeFrame(.horizontal) { length, _ in length - 32 }
                }

                // Новый контрол — светящиеся бобы. activeIndex и glowLevel — из того
                // же источника, что и вспышка картинки → синхрон гарантирован.
                BobsControl(activeIndex: beatIndex % 4, glowOn: glowOn, glowLevel: glowLevel)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, 8)

            // Рулер + кнопки (ниже).
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
                        .brightness(darkButtonPressed ? 0.15 : 0)
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    if !darkButtonPressed {
                                        withAnimation(.easeOut(duration: 0.08)) { darkButtonPressed = true }
                                    }
                                }
                                .onEnded { _ in
                                    withAnimation(.easeOut(duration: 0.15)) { darkButtonPressed = false }
                                }
                        )

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
                        .brightness(whiteButtonPressed ? 0.2 : 0)
                        .saturation(whiteButtonPressed ? 1.5 : 1)
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    if !whiteButtonPressed {
                                        withAnimation(.easeOut(duration: 0.08)) { whiteButtonPressed = true }
                                    }
                                }
                                .onEnded { _ in
                                    withAnimation(.easeOut(duration: 0.15)) { whiteButtonPressed = false }
                                }
                        )
                    }
                    .frame(width: 240)
                }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .offset(y: 40)  // опущено ниже

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

    /// Вкл/выкл подсветку. Включённая — БЬЁТСЯ метрономом (90 bpm): на каждый удар
    /// картинка вспыхивает И загорается следующий боб. Оба изменения — в одном
    /// callback таймера, читают одно glowLevel → синхрон физически гарантирован.
    private func toggleGlow() {
        glowOn.toggle()
        if glowOn {
            beatIndex = 0
            startBeat()
        } else {
            beatTimer?.invalidate()
            beatTimer = nil
            withAnimation(.easeInOut(duration: 0.35)) { glowLevel = 0.5 }
        }
    }

    /// Запустить метроном: сразу первый удар, затем по таймеру.
    /// Режим .common — таймер не замирает во время свайпа по рулеру.
    private func startBeat() {
        beatTimer?.invalidate()
        flashBeat()  // первый удар сразу (боб 0)
        let timer = Timer(timeInterval: beatInterval, repeats: true) { _ in
            beatIndex += 1
            flashBeat()
        }
        RunLoop.main.add(timer, forMode: .common)
        beatTimer = timer
    }

    /// Один удар метронома: резкая вспышка (snap до 1.0) → быстрое затухание.
    /// Боб переключается через beatIndex в том же callback → синхронно с вспышкой.
    private func flashBeat() {
        glowLevel = 1.0  // мгновенно — резкая «атака» удара
        withAnimation(.easeOut(duration: 0.25)) {
            glowLevel = 0.5  // быстрое затухание к следующему удару
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
