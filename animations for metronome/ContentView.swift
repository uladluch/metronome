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

    /// Значение «линейки» (tick-слайдер) под кнопками.
    @State private var tempo: Double = 120

    /// Видны ли кнопки +/- (по умолчанию скрыты, появляются при взаимодействии).
    @State private var controlsVisible = false
    @State private var hideTask: Task<Void, Never>?

    /// Главный шит — общий для верхних кнопок (шестерёнка/капсула/троеточие) и
    /// нижней левой кнопки. Уникальный BPM-шит живёт в BottomToolbar (низ-право).
    @State private var showMainSheet = false

    /// Блик Shine под белой кнопкой (под пальцем, под стеклом).
    @State private var whitePressed = false
    @State private var whiteTouchPoint: CGPoint = .zero

    /// Показать ли нотификацию.
    @State private var showNotification = false
    /// Текст нотификации (меняется в зависимости от того, кто её вызвал).
    @State private var notificationText = "Hello I'm notification"
    /// Отложенное скрытие нотификации (2.5с). DispatchWorkItem — чтобы withAnimation
    /// гарантированно проигрывал transition (внутри Task после await не работает).
    @State private var notificationHideWork: DispatchWorkItem?

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
                        onLeft: { showMainSheet = true },
                        onCenter: { showMainSheet = true },
                        onRight: { showMainSheet = true }
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
                            disabled: tempo <= 40,
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
                            disabled: tempo >= 240,
                            onShow: showControls,
                            onStep: { step(1) },
                            onHide: scheduleHide
                        )
                    }

                    // Две кнопки glow (теперь СНИЗУ).
                    VStack(spacing: 12) {
                        // Тёмная стеклянная кнопка — показать нотификацию.
                        GlassButton(
                            shape: Capsule(),
                            namespace: glassNS,
                            action: { showNotificationAction() },
                            showDome: false,
                            pressScale: 1.08,
                            glassStyle: .regular,
                            showShine: true,
                            shineImage: "shine 2",
                            shineOpacity: 0.2,
                            shineHorizontalOnly: true,
                            shineWidthFactor: 1.6,
                            shineHeightFactor: 3
                        ) {
                            Text("Show notification")
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
                                // Shine 3 ПОВЕРХ всего (над стеклом), под пальцем, по
                                // горизонтали; обрезается капсулой.
                                .overlay {
                                    GeometryReader { g in
                                        Image("shine 3")
                                            .resizable()
                                            .frame(width: g.size.width * 1.6, height: g.size.height * 3)
                                            .position(
                                                x: whiteTouchPoint == .zero ? g.size.width / 2 : whiteTouchPoint.x,
                                                y: g.size.height / 2
                                            )
                                            .opacity(whitePressed ? 1 : 0)
                                            .animation(.easeOut(duration: 0.4), value: whitePressed)
                                            .animation(.easeOut(duration: 0.55), value: whiteTouchPoint)
                                            .allowsHitTesting(false)
                                    }
                                }
                                .clipShape(Capsule())
                                .contentShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        // Тот же зум на нажатии, что и у чёрной (pressScale 1.08).
                        .scaleEffect(whitePressed ? 1.08 : 1.0)
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { v in
                                    whiteTouchPoint = v.location
                                    if !whitePressed {
                                        withAnimation(.easeOut(duration: 0.12)) { whitePressed = true }
                                    }
                                }
                                .onEnded { _ in
                                    withAnimation(.easeOut(duration: 0.3)) { whitePressed = false }
                                }
                        )
                    }
                    .frame(width: 240)
                }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .offset(y: 40)  // опущено ниже

            // Нижний тулбар — прижат к низу. Левая кнопка открывает тот же главный шит.
            BottomToolbar(
                onMainSheet: { showMainSheet = true },
                onBPMOverflow: {
                    // Небольшая задержка — чтобы баннер влетел уже после закрытия шита.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                        showNotificationAction("Maximum value can't exceed 360")
                    }
                }
            )
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 8)

            // Нотификация — ВСЕГДА в дереве, анимируем opacity (+ лёгкий scale/offset)
            // через состояние. Анимация СВОЙСТВ работает в обе стороны железно, в
            // отличие от .transition при условном вставлении/удалении. Обычный child
            // ZStack (НЕ overlay) → уважает safe area.
            HStack(spacing: 12) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                Text(notificationText)
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)              // внутренний отступ контента
            .frame(width: 360, height: 60)         // фиксированная ширина
            .glassEffect(.regular, in: Capsule())   // капсула — полностью скруглённая
            .shadow(color: .black.opacity(0.25), radius: 20, y: 8)  // глубина
            .padding(.top, 8)                       // отступ от верха
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)  // центр X, верх
            // Эффектный влёт сверху: большой offset (из-за верхнего края) + scale +
            // fade. Всё через состояние → надёжно работает в обе стороны.
            .opacity(showNotification ? 1 : 0)
            .scaleEffect(showNotification ? 1 : 0.9, anchor: .top)
            .offset(y: showNotification ? 0 : -120)
            .allowsHitTesting(showNotification)     // скрытая не перехватывает тапы
        }
        // Главный шит — общий для верхних кнопок и нижней левой.
        .sheet(isPresented: $showMainSheet) {
            SheetView()
                .presentationDetents([.large])           // только .large (не medium)
                .presentationDragIndicator(.visible)     // grabber сверху
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

    /// Показать нотификацию (с заданным текстом) и скрыть через 2.5s.
    /// Apple-style: вход и выход — одна и та же красивая пружина (зеркально).
    private func showNotificationAction(_ text: String = "Hello I'm notification") {
        notificationText = text
        notificationHideWork?.cancel()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.72)) {
            showNotification = true
        }
        // DispatchQueue.main.asyncAfter (а НЕ Task): withAnimation в чистом тике
        // runloop надёжно проигрывает transition удаления.
        let work = DispatchWorkItem {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.72)) {
                showNotification = false
            }
        }
        notificationHideWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: work)
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
