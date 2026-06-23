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
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // Окна. У каждого тот же glassEffectID, что у его кнопки,
                    // поэтому стекло кнопки морфит в окно и обратно.
                    if openPanel == .left {
                        GlassPanel(position: .left, namespace: glassNS, onClose: close)
                    }
                    if openPanel == .center {
                        GlassPanel(position: .center, namespace: glassNS, onClose: close)
                    }
                    if openPanel == .right {
                        GlassPanel(position: .right, namespace: glassNS, onClose: close)
                    }
                }
            }
        }
    }

    private func open(_ panel: PanelPosition) {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
            openPanel = panel
        }
    }

    private func close() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
            openPanel = nil
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
