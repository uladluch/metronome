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

                    // Закрытие по тапу мимо окна (нижняя часть экрана).
                    if openPanel != nil {
                        Color.clear
                            .contentShape(Rectangle())
                            .ignoresSafeArea()
                            .onTapGesture { close() }
                    }

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
                        print("[ContentView] GlowOn toggled: \(glowOn)")
                    }
                },
                showDome: false  // Без сферы — только на круглых кнопках.
            ) {
                Text(glowOn ? "Turn off glow" : "Turn on glow")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .frame(height: 50)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

            // Цветной свет под стеклом — видно везде, не обрезается.
            // Выложена перед BottomToolbar, чтобы быть видимой поверх контейнера.
            GlassBackdrop(glowOn: glowOn)
                .zIndex(-1)  // За всем остальным, но впереди фона.

            // Нижний тулбар — прижат к низу.
            BottomToolbar()
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 8)
        }
    }

    // Лёгкая пружина — едва заметный отскок.
    private let morphAnimation: Animation = .spring(response: 0.4, dampingFraction: 0.74)

    private func open(_ panel: PanelPosition) {
        withAnimation(morphAnimation) {
            openPanel = panel
        }
    }

    private func close() {
        withAnimation(morphAnimation) {
            openPanel = nil
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
