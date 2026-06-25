//
//  GlassPanel.swift
//  animations for metronome
//
//  Нативный sheet настроек. Открывается из кнопки-шестерёнки с zoom-переходом
//  (.navigationTransition(.zoom) ↔ .matchedTransitionSource на кнопке) — система
//  сама «вырастает» окно из кнопки. Фон, тулбар, крестик — нативные.
//

import SwiftUI

struct SettingsSheet: View {

    @Environment(\.dismiss) private var dismiss

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
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
