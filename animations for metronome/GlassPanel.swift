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
            // Убирает серый фон контейнера NavigationStack → стекло под ним видно.
            .containerBackground(.clear, for: .navigation)
            .scrollContentBackground(.hidden)
        }
        // Крестик — НЕ в ToolbarItem (там iOS даёт второе стекло → «кнопка в кнопке»),
        // а отдельным overlay со своим контролируемым стеклом 40×40.
        .overlay(alignment: .topTrailing) {
            CloseButton(action: onClose)
                .padding(.trailing, 10)
                .padding(.top, 2)
        }
    }
}
