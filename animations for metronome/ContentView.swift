//
//  ContentView.swift
//  animations for metronome
//
//  Created by Ulad Luch on 23/06/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            // Тёмная тема: основной фон полностью чёрный.
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                TopToolbar()
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                Spacer()

                // Здесь позже появится нижний тулбар.
            }
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
