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

    /// Открыть главный шит (тот же, что и верхние кнопки) — состояние живёт в ContentView.
    var onMainSheet: () -> Void = {}

    @State private var value: Double = 0.5
    @State private var showBPM = false

    /// Иконки громкости видны только во время взаимодействия со слайдером.
    @State private var showVolumeIcons = false

    // Угловые иконки-фигуры: низ-лево — квадрат, низ-право — ромб (не повторяются
    // с верхними круг/треугольник).
    private let leftIcon = "square"
    private let rightIcon = "diamond"

    var body: some View {
        // Тот же GlassEffectContainer, что и сверху — чтобы стекло на кнопках
        // вело себя одинаково в обоих тулбарах.
        GlassEffectContainer(spacing: 16) {
            HStack(spacing: 16) {
                GlassIconButton(
                    systemName: leftIcon,
                    glassID: nil,
                    namespace: ns,
                    action: { onMainSheet() }
                )

                // Слайдер с иконками громкости по бокам. Иконки всегда занимают
                // место (через opacity) → слайдер уже и не «прыгает».
                HStack(spacing: 8) {
                    Image(systemName: "speaker.wave.1.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(.white)
                        .opacity(showVolumeIcons ? 1 : 0)

                    Slider(value: $value, onEditingChanged: { editing in
                        if editing {
                            withAnimation(.easeOut(duration: 0.15)) { showVolumeIcons = true }
                        } else {
                            // Затухают за 300ms после взаимодействия.
                            withAnimation(.easeInOut(duration: 0.3)) { showVolumeIcons = false }
                        }
                    })
                    .tint(.controlAccent)
                    // Очень нежный хаптик на каждые 5% слайдера.
                    .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.4),
                                     trigger: Int(value * 20))

                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(.white)
                        .opacity(showVolumeIcons ? 1 : 0)
                }

                // Правая кнопка — второй шит (ввод BPM).
                GlassIconButton(
                    systemName: rightIcon,
                    glassID: nil,
                    namespace: ns,
                    action: { showBPM = true }
                )
            }
            .frame(height: 60)
            // Конкретная ширина = экран − 32 (по 16pt с боков), центр.
            .containerRelativeFrame(.horizontal) { length, _ in length - 32 }
        }
        // Уникальный шит — ввод BPM (нижняя правая кнопка). Пока на весь экран.
        .sheet(isPresented: $showBPM) {
            BPMSheet()
        }
    }
}

// MARK: - Контент полноэкранного sheet

/// Главный шит — общий для верхних кнопок и нижней левой. Презентуется из ContentView.
struct SheetView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var toggleOn = true
    @State private var sliderValue: Double = 0.5
    @State private var showPopover = false
    @State private var containerWidth: CGFloat = 0

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
                            // Тот же нежный хаптик, что и у слайдера в тулбаре.
                            .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.4),
                                             trigger: Int(sliderValue * 20))
                    }

                    // Popover row
                    HStack {
                        Text("Popover")
                        Spacer()
                        Button("Show") {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            showPopover = true
                        }
                        .popover(isPresented: $showPopover, arrowEdge: .top) {
                            Text("Hello")
                                .font(.title.bold())
                                .foregroundStyle(.white)
                                .frame(width: containerWidth > 0 ? containerWidth : 360,
                                       height: 280)
                                .multilineTextAlignment(.center)
                                // На iPhone (compact) форсируем именно popover, а не sheet.
                                .presentationCompactAdaptation(.popover)
                        }
                    }
                }

                // Большой длинный блок — просто чтобы шит скроллился. Подсказка
                // пользователю: проскролль и посмотри, как затемняется топ-тулбар.
                Section("Scroll") {
                    Text("Scroll up — watch the top toolbar dim as the content scrolls under it.")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: 900, alignment: .top)
                        .padding(.top, 40)
                }
            }
            .navigationTitle("Sheet")
            // Стандартный large: большой заголовок, сворачивается в inline при скролле.
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                // Крестик справа — закрыть (единственная кнопка).
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
        // Ширина контейнера для popover на всю ширину.
        .onGeometryChange(for: CGFloat.self, of: { $0.size.width }, action: { containerWidth = $0 })
    }
}
