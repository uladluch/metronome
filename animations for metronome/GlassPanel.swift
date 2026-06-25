//
//  GlassPanel.swift
//  animations for metronome
//
//  Внутренний контент панели, который раскрывается из шестерёнки через
//  ExpandableGlassMenu. Включает NavigationStack с toolbar и inline title.
//

import SwiftUI

struct PanelContent: View {

    @Namespace private var ns
    var onClose: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Toolbar с крестиком (аналог sheet'а).
                HStack {
                    Text("Settings")
                        .font(.title.bold())
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

                Divider()
                    .background(Color.white.opacity(0.1))

                // Контент
                VStack {
                    Text("Settings Panel")
                        .foregroundStyle(.white)
                        .font(.headline)

                    Spacer()
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
