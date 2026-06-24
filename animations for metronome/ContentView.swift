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

    /// Какая панель сейчас открыта (nil — закрыты все).
    @State private var openPanel: PanelPosition?

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
                        openPanel: openPanel,
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

                    // Окна. У каждого тот же glassEffectID, что у его кнопки,
                    // поэтому стекло кнопки морфит в окно и обратно.
                    // zIndex(1) — окно гарантированно поверх тулбара и слоя-закрытия.
                    if openPanel == .left {
                        GlassPanel(position: .left, namespace: glassNS, onClose: close)
                            .zIndex(1)
                    }
                    if openPanel == .center {
                        GlassPanel(position: .center, namespace: glassNS, onClose: close)
                            .zIndex(1)
                    }
                    if openPanel == .right {
                        GlassPanel(position: .right, namespace: glassNS, onClose: close)
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

    // EaseInOut для плавного морфинга shapes — форма меняется медленнее.
    private let morphAnimation: Animation = .easeInOut(duration: 1.0)

    private func open(_ panel: PanelPosition) {
        print("[ContentView] Opening panel: \(panel)")
        withAnimation(morphAnimation) {
            openPanel = panel
            print("[ContentView] openPanel set to: \(String(describing: openPanel))")
        }
    }

    private func close() {
        print("[ContentView] Closing panel")
        withAnimation(morphAnimation) {
            openPanel = nil
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
