//
//  GlassPanel.swift
//  animations for metronome
//
//  Внутренний контент панели, который раскрывается из шестерёнки через
//  ExpandableGlassMenu. Inline title с системным close button в toolbar.
//

import SwiftUI

struct PanelContent: View {

    @Environment(\.dismiss) private var dismiss
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
            .background(Color.clear)  // Glass effect: прозрачный фон вместо серого
        }
    }
}
