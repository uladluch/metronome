//
//  GlassPanel.swift
//  animations for metronome
//
//  Внутренний контент панели, который раскрывается из шестерёнки через
//  ExpandableGlassMenu. NavigationStack с нативным toolbar и inline-тайтлом —
//  кнопка-крестик нативная (её рисует ToolbarItem). Прозрачность navigation bar
//  глобально настроена в App.init (UINavigationBarAppearance), плюс
//  .toolbarBackground(.hidden) — поэтому стекло видно и фон не светлеет.
//

import SwiftUI

struct PanelContent: View {

    var onClose: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        onClose()
                    }) {
                        Image(systemName: "xmark")
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}
