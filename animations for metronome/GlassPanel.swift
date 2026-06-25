//
//  GlassPanel.swift
//  animations for metronome
//
//  Внутренний контент панели, который раскрывается из шестерёнки через
//  ExpandableGlassMenu. Toolbar с inline маленьким тайтлом и крестиком,
//  glass effect сохраняется (прозрачный фон).
//

import SwiftUI

struct PanelContent: View {

    @Namespace private var ns
    var onClose: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Toolbar с крестиком.
                HStack {
                    Text("Settings")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Spacer()

                    GlassButton(
                        shape: Circle(),
                        namespace: ns,
                        action: onClose,
                        showDome: false
                    ) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(20)

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.clear)  // Glass effect: прозрачный фон вместо серого
        }
    }
}
