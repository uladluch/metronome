//
//  ContentView.swift
//  animations for metronome
//
//  Created by Ulad Luch on 23/06/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var showLeftPanel = false
    @State private var showRightPanel = false
    @State private var showCenterPanel = false

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                TopToolbar(
                    onLeftTap: { showLeftPanel = true },
                    onRightTap: { showRightPanel = true },
                    onCenterTap: { showCenterPanel = true }
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()
            }

            if showLeftPanel {
                GlassPanel(position: .left, isPresented: $showLeftPanel)
                    .glassEffectTransition(.identity)
            }

            if showRightPanel {
                GlassPanel(position: .right, isPresented: $showRightPanel)
                    .glassEffectTransition(.identity)
            }

            if showCenterPanel {
                GlassPanel(position: .center, isPresented: $showCenterPanel)
                    .glassEffectTransition(.identity)
            }
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
