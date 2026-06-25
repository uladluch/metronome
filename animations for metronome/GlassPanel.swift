//
//  GlassPanel.swift
//  animations for metronome
//
//  Внутренний контент панели, который раскрывается из шестерёнки через
//  ExpandableGlassMenu. NavigationStack с нативным toolbar и inline-тайтлом.
//  Крестик — голый Image в ToolbarItem (стекло даёт сам тулбар, без «кнопки в
//  кнопке»). Серый фон КОНТЕЙНЕРА убран (.containerBackground(.clear)), а стекло
//  самого bar явно включено (.toolbarBackground(.visible)).
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
            // Фон окна задаёт сам NavigationStack (override-прозрачность убрана),
            // стекло toolbar-bar — явно видимое.
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}
