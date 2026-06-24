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

    var body: some View {
        ZStack(alignment: .top) {
            // Тёмная тема: основной фон полностью чёрный.
            Color.appBackground
                .ignoresSafeArea()

            // Цветной свет под стеклом — стеклу есть что преломлять,
            // отсюда радужное переливание на кромке.
            GlassBackdrop()

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
            .padding(.horizontal, 16)
        }
    }

    // Морф почти без пружины: .smooth — мягкое затухание без «отскока».
    private let morphAnimation: Animation = .smooth(duration: 0.4)

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
