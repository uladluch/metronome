//
//  animations_for_metronomeApp.swift
//  animations for metronome
//
//  Created by Ulad Luch on 23/06/2026.
//

import SwiftUI

@main
struct animations_for_metronomeApp: App {

    init() {
        // Глобально: прозрачный navigation bar (без материала-блюра), чтобы
        // стекло под NavigationStack было видно и фон не светлел.
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Пока что только тёмная тема.
                .preferredColorScheme(.dark)
        }
    }
}
