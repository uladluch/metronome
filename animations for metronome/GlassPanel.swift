//
//  GlassPanel.swift
//  animations for metronome
//
//  Внутренний контент панели, который раскрывается из шестерёнки через
//  ExpandableGlassMenu. Тулбар собран вручную (БЕЗ NavigationStack) — он добавлял
//  непрозрачный системный фон и осветлял стекло. Inline-тайтл по центру + standalone
//  системная glass-кнопка (CloseButton). В sheet используется нативная кнопка
//  тулбара (там стекло даёт сам ToolbarItem).
//

import SwiftUI

struct PanelContent: View {

    var onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Самодельный inline-тулбар: тайтл по центру, крестик справа.
            ZStack {
                Text("Settings")
                    .font(.headline)
                    .foregroundStyle(.white)

                HStack {
                    Spacer()
                    CloseButton(action: onClose)  // та же кнопка, что в sheet
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 56)

            Spacer()
        }
    }
}
