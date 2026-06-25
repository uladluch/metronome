//
//  GlassPanel.swift
//  animations for metronome
//
//  Внутренний контент панели, который раскрывается из шестерёнки через
//  ExpandableGlassMenu. Тулбар собран вручную (БЕЗ NavigationStack) — он добавлял
//  непрозрачный системный фон и осветлял стекло. Inline-тайтл по центру + нативная
//  iOS 26 glass-кнопка (.buttonStyle(.glass)), как системная в sheet.
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
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        onClose()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.glass)  // нативная iOS 26 glass-кнопка (как в sheet)
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 56)

            Spacer()
        }
    }
}
