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
                .presentationDetents([.large])           // только .large (не medium)
                .presentationDragIndicator(.visible)     // grabber сверху
        }
    }
}

// MARK: - Контент полноэкранного sheet

private struct SheetView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var toggleOn = true
    @State private var sliderValue: Double = 0.5
    @State private var selectedSegment = 0

    var body: some View {
        NavigationStack {
            Form {
                Section("Microanimations") {
                    // Toggle row
                    HStack {
                        Text("Toggle")
                        Spacer()
                        Toggle("", isOn: $toggleOn)
                            .tint(.controlAccent)
                            .onChange(of: toggleOn) { _, _ in
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                    }

                    // Slider row
                    HStack {
                        Text("Slider")
                        Spacer()
                        Slider(value: $sliderValue, in: 0...1)
                            .frame(maxWidth: 150)
                            .tint(.controlAccent)
                            .onChange(of: sliderValue) { _, _ in
                                UISelectionFeedbackGenerator().selectionChanged()
                            }
                    }

                    // Segmented Control row
                    HStack {
                        Text("Segment")
                        Spacer()
                        Picker("", selection: $selectedSegment) {
                            Text("Fast").tag(0)
                            Text("Normal").tag(1)
                            Text("Slow").tag(2)
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: selectedSegment) { _, _ in
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                        .frame(maxWidth: 180)
                    }
                }
            }
            .navigationTitle("Sheet")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                // Нативная кнопка тулбара — iOS 26 сама оборачивает в Liquid Glass.
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
    }
}
