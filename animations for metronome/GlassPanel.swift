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
                    // Голый крестик без обёртки в Button — стекло даёт сам тулбар,
                    // своей кнопки нет → не должно быть «кнопки в кнопке».
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            onClose()
                        }
                }
            }
            // Убирает серый фон контейнера NavigationStack → стекло под ним видно.
            .containerBackground(.clear, for: .navigation)
            .scrollContentBackground(.hidden)
        }
    }
}
