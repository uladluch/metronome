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

    // Spring морфинга: правильный выбор для liquid glass morphing.
    private let morphAnimation: Animation = .spring(response: 0.6, dampingFraction: 0.8)

    var body: some View {
        let panelW = max(screenSize.width - 32, 0)
        let panelH = max(screenSize.height * 0.45, 0)

        // Тулбар угасает при раскрытии панели (0→0.25 морфа).
        let toolbarFade = 1 - min(morphProgress / 0.25, 1)

        ZStack(alignment: .top) {
            // Тёмная тема: основной фон полностью чёрный.
            Color.appBackground
                .ignoresSafeArea()

            // Цветной свет под стеклом (lensing).
            GlassBackdrop(glowOn: glowOn)

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

            // Тулбар (капсула + три точки) + шестерёнка-оверлей.
            // Шестерёнка — overlay НА тулбаре, выровнена по его topLeading (= слот
            // шестерёнки слева, x=16). Привязка к кадру тулбара гарантирует
            // совпадение позиций, а панель растёт ровно в ширину тулбара
            // (экран−32 = 16pt по бокам).
            // .opacity ДО .overlay → угасает только тулбар, шестерёнка НЕ угасает.
            TopToolbar(
                namespace: glassNS,
                onCenter: {},
                onRight: {}
            )
            .containerRelativeFrame(.horizontal) { length, _ in length - 32 }
            .opacity(toolbarFade)
            .overlay(alignment: .topLeading) {
                ExpandableGlassMenu(
                    alignment: .topLeading,
                    progress: morphProgress,
                    labelSize: .init(width: 60, height: 60),
                    cornerRadius: 40
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
            }
            .padding(.top, 8)
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
