//
//  ContentView.swift
//  animations for metronome
//
//  Created by Ulad Luch on 23/06/2026.
//

import SwiftUI

struct ContentView: View {

    /// Общий namespace для морфинга Liquid Glass между кнопками и панелями.
    @Namespace private var glassNS

    /// Какая панель сейчас открывается (nil — закрыты все).
    @State private var activePanel: PanelPosition?

    /// Прогресс морфинга: 0 = кнопка, 1 = полная панель.
    /// Stage 1 (0→0.5): кнопка растягивается в овал (scaleY, cornerRadius).
    /// Stage 2 (0.5→1): овал раскрывается в полную панель.
    @State private var morphProgress: CGFloat = 0

    /// Подсветка (свечение Path) вкл/выкл. По умолчанию выключена.
    @State private var glowOn = false

    var body: some View {
        ZStack(alignment: .top) {
            // Тёмная тема: основной фон полностью чёрный.
            Color.appBackground
                .ignoresSafeArea()

            // Цветной свет под стеклом — размещена ДО контейнера, чтобы капсула
            // преломляла её через стекло (Liquid Glass lensing effect).
            GlassBackdrop(glowOn: glowOn)

            // Один контейнер на тулбар + панели — обязательное условие морфинга:
            // стекло может «перетекать» только внутри одного GlassEffectContainer.
            GlassEffectContainer(spacing: 16) {
                ZStack(alignment: .top) {
                    TopToolbar(
                        namespace: glassNS,
                        activePanel: activePanel,
                        morphProgress: morphProgress,
                        onLeft: { open(.left) },
                        onCenter: { open(.center) },
                        onRight: { open(.right) }
                    )
                    // Конкретная ширина = экран − 32 (по 16pt с боков), центр.
                    // containerRelativeFrame берёт ширину от экрана, мимо
                    // «неограниченного» предложения GlassEffectContainer — тот же
                    // приём, что уже корректно сайзит панели.
                    .containerRelativeFrame(.horizontal) { length, _ in length - 32 }
                    .padding(.top, 8)

                    // Окна. Отображаются на основе morphProgress.
                    // Stage 2 (progress > 0.5) — панель становится видима и раскрывается.
                    if let panel = activePanel {
                        GlassPanel(
                            position: panel,
                            namespace: glassNS,
                            morphProgress: morphProgress,
                            onClose: close
                        )
                        .zIndex(1)
                    }
                }
            }

            // Кнопка по центру: включает/выключает подсветку (свечение Path).
            GlassButton(
                shape: Capsule(),
                namespace: glassNS,
                action: {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        glowOn.toggle()
                    }
                },
                showDome: false
            ) {
                Text(glowOn ? "Turn off glow" : "Turn on glow")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .frame(height: 50)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .offset(y: 80)  // Опустить пониже

            // Нижний тулбар — прижат к низу.
            BottomToolbar()
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 8)
        }
    }

    // Spring с лёгким bounce для морфинга.
    private let morphAnimation: Animation = .spring(response: 0.55, dampingFraction: 0.78)

    private func open(_ panel: PanelPosition) {
        print("[ContentView] Opening panel: \(panel)")
        activePanel = panel
        withAnimation(morphAnimation) {
            morphProgress = 1
        }
    }

    private func close() {
        print("[ContentView] Closing panel")
        withAnimation(morphAnimation) {
            morphProgress = 0
        }
        // После завершения анимации очистим activePanel
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            activePanel = nil
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
