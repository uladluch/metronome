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

    /// Namespace для zoom-перехода sheet'а из шестерёнки.
    @Namespace private var sheetNS

    /// Подсветка (свечение Path) вкл/выкл.
    @State private var glowOn = false

    /// Открыт ли sheet настроек (открывается из шестерёнки).
    @State private var showSettings = false

    var body: some View {
        ZStack(alignment: .top) {
            // Тёмная тема: основной фон полностью чёрный.
            Color.appBackground
                .ignoresSafeArea()

            // Цветной свет под стеклом (lensing).
            GlassBackdrop(glowOn: glowOn)

            // Верхний тулбар: шестерёнка (открывает sheet) + капсула + три точки.
            GlassEffectContainer(spacing: 16) {
                TopToolbar(
                    namespace: glassNS,
                    sheetNamespace: sheetNS,
                    onLeft: { showSettings = true },
                    onCenter: {},
                    onRight: {}
                )
                .containerRelativeFrame(.horizontal) { length, _ in length - 32 }
                .padding(.top, 8)
            }

            // Кнопка по центру: включает/выключает подсветку (свечение Path).
            GlassButton(
                shape: Capsule(),
                namespace: glassNS,
                action: {
                    withAnimation(.easeInOut(duration: 0.35)) { glowOn.toggle() }
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
            .offset(y: 80)

            // Нижний тулбар — прижат к низу.
            BottomToolbar()
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 8)
        }
        // Нативный sheet, который «вырастает» (zoom) из шестерёнки.
        .sheet(isPresented: $showSettings) {
            SettingsSheet()
                .navigationTransition(.zoom(sourceID: "gear", in: sheetNS))
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
