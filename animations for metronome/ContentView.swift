//
//  ContentView.swift
//  animations for metronome
//
//  Created by Ulad Luch on 23/06/2026.
//

import SwiftUI

struct ContentView: View {

    /// Namespace для GlassButton-обёрток (капсула/кнопки) — морфинга у них нет.
    @Namespace private var glassNS

    /// Прогресс раскрытия шестерёнки в панель: 0 = кнопка, 1 = панель.
    @State private var morphProgress: CGFloat = 0

    /// Подсветка (свечение Path) вкл/выкл. По умолчанию выключена.
    @State private var glowOn = false

    /// Размер экрана (для размера контента панели).
    @State private var screenSize: CGSize = .zero

    // Bouncy: симметрично по времени (открытие = закрытие наоборот) + лёгкий inflate.
    private let morphAnimation: Animation = .bouncy(duration: 0.6, extraBounce: 0.1)

    var body: some View {
        let panelW = max(screenSize.width - 32, 0)
        let panelH = max(screenSize.height * 0.5, 0)

        ZStack(alignment: .top) {
            // Тёмная тема: основной фон полностью чёрный.
            Color.appBackground
                .ignoresSafeArea()

            // Цветной свет под стеклом (lensing).
            GlassBackdrop(glowOn: glowOn)

            // Верхний тулбар (капсула + три точки). Угасает по мере раскрытия панели.
            TopToolbar(
                namespace: glassNS,
                onCenter: {},
                onRight: {}
            )
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .frame(maxWidth: .infinity, alignment: .top)
            .opacity(1 - min(morphProgress / 0.25, 1))

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

            // Шестерёнка → панель. Закреплена в верхнем левом углу через clear-филлер,
            // чтобы ExpandableGlassMenu сохранял свой размер (а не растягивал стекло
            // на весь экран). Растёт из угла кнопки 60×60 в панель panelW × panelH.
            ZStack(alignment: .topLeading) {
                Color.clear
                ExpandableGlassMenu(
                    alignment: .topLeading,
                    progress: morphProgress,
                    labelSize: .init(width: 60, height: 60),
                    cornerRadius: 50
                ) {
                    PanelContent(onClose: close)
                        .frame(width: panelW, height: panelH, alignment: .topLeading)
                        .allowsHitTesting(morphProgress > 0.5)
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .contentShape(Circle())
                        .onTapGesture { open() }
                        .allowsHitTesting(morphProgress == 0)
                }
                .padding(.leading, 16)
                .padding(.top, 8)
            }
            .zIndex(1)
        }
        .onGeometryChange(for: CGSize.self, of: { $0.size }, action: { screenSize = $0 })
    }

    private func open() {
        withAnimation(morphAnimation) { morphProgress = 1 }
    }

    private func close() {
        withAnimation(morphAnimation) { morphProgress = 0 }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
