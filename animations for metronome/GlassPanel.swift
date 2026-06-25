//
//  GlassPanel.swift
//  animations for metronome
//
//  Внутренний контент панели, который раскрывается из шестерёнки через
//  ExpandableGlassMenu. Inline title с системным close button в toolbar.
//

import SwiftUI

struct PanelContent: View {

    var onClose: () -> Void

    var body: some View {
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
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(.white.opacity(0.6))
                .tint(.white.opacity(0.6))
            }
        }
        .background(Color.clear)
    }
}
