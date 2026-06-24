//
//  BottomToolbar.swift
//  animations for metronome
//
//  Нижний тулбар: по бокам такие же стеклянные кнопки 60×60, что и сверху,
//  а по центру — нативный SwiftUI Slider (вместо капсулы).
//  Кнопки-квадраты открывают нативный sheet с grabber'ом (свайпаемый).
//

import SwiftUI

struct BottomToolbar: View {

    // Кнопки тут не морфят, namespace нужен только для сигнатуры.
    @Namespace private var ns

    @State private var value: Double = 0.5
    @State private var showSheet = false

    private let icon = "square"

    var body: some View {
        // Тот же GlassEffectContainer, что и сверху — чтобы стекло на кнопках
        // вело себя одинаково в обоих тулбарах.
        GlassEffectContainer(spacing: 16) {
            HStack(spacing: 16) {
                GlassIconButton(
                    systemName: icon,
                    glassID: nil,
                    namespace: ns,
                    action: { showSheet = true }
                )

                // Нативный слайдер по центру, активный трек — #EDEDED.
                Slider(value: $value)
                    .tint(.controlAccent)

                GlassIconButton(
                    systemName: icon,
                    glassID: nil,
                    namespace: ns,
                    action: { showSheet = true }
                )
            }
            .frame(height: 60)
            // Конкретная ширина = экран − 32 (по 16pt с боков), центр.
            .containerRelativeFrame(.horizontal) { length, _ in length - 32 }
        }
        .sheet(isPresented: $showSheet) {
            SheetView()
                .presentationDetents([.medium, .large])  // Half-screen + full-screen
                .presentationDragIndicator(.visible)    // grabber сверху
        }
    }
}

// MARK: - Контент полноэкранного sheet

private struct SheetView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var isOn = true

    var body: some View {
        NavigationStack {
            ZStack {
                // Фон со стеклом — вместо плоского secondarySystemBackground.
                Color(.secondarySystemBackground)
                    .ignoresSafeArea()
                    .overlay {
                        // Glass layer поверх фона
                        Rectangle()
                            .fill(.clear)
                            .glassEffect(.regular.interactive())
                            .ignoresSafeArea()
                    }

                VStack {
                    Toggle("Toggle", isOn: $isOn)
                        .tint(.controlAccent)   // не зелёный, а #EDEDED
                        .padding()
                    Spacer()
                }
            }
            .navigationTitle("Sheet")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                // Крестик в тулбаре — в iOS 26 кнопка тулбара уже Liquid Glass.
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}
