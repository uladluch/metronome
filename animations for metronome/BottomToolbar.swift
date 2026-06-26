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
    /// Выбранная вкладка верхнего сегмент-контрола.
    @State private var segment = 0

    var body: some View {
        NavigationStack {
            Form {
                // Блок с сегментом сверху и контентом, который меняется по выбору.
                // Едет вместе со скроллом (не закреплён).
                Section {
                    // Карточка: сегмент + контент внутри одного блока. Фон 3-го уровня,
                    // padding 16pt со всех сторон, без сепаратора.
                    VStack(spacing: 16) {
                        GlassSegmentedControl(
                            titles: ["First", "Second"],
                            selection: $segment,
                            height: 46
                        )

                        // Контент блока — просто текст по центру, меняется по выбору.
                        Text(segment == 0 ? "Segment A" : "Segment B")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    // Внутренний padding: 16 по бокам, 32 сверху/снизу.
                    .padding(.horizontal, 16)
                    .padding(.vertical, 32)
                    .background(
                        Color(.tertiarySystemBackground),
                        in: RoundedRectangle(cornerRadius: 28, style: .continuous)
                    )
                    // На всю ширину контейнера (без боковых insets) + внешний margin 16 сверху/снизу.
                    .listRowInsets(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

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
            // inlineLarge: крупный заголовок, зафиксированный в баре по левому краю —
            // НЕ сворачивается и не двигается при скролле.
            .toolbarTitleDisplayMode(.inlineLarge)
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

// MARK: - Текстовый сегмент-таб с нативным liquid glass

/// Текстовый сегмент-контрол (по мотивам kai7win/AnimatedGlassTabs).
/// Подписи рисуем сами — SwiftUI-оверлей с плавной сменой цвета, — а под ними
/// прячется нативный UISegmentedControl с прозрачными заголовками, который даёт
/// родное liquid-glass переключение (скользящую подсветку) и ловит тапы. Высоту
/// задаём снаружи, чего Picker(.segmented) не умеет.
struct GlassSegmentedControl: View {

    let titles: [String]
    @Binding var selection: Int
    var height: CGFloat = 46

    /// Палец на контроле — подсветка «уходит в стекло», поэтому чёрный активный
    /// текст красим в белый, чтобы оставался читаемым.
    @State private var pressing = false

    var body: some View {
        GlassEffectContainer(spacing: 10) {
            GeometryReader { geo in
                // 1) Нативная подложка: невидимые заголовки + liquid-glass подсветка.
                //    pressing обновляется по нативным touch-событиям UIControl —
                //    SwiftUI-жест конфликтовал бы со скроллом Form и ломал тапы.
                SegmentedBacking(size: geo.size, count: titles.count,
                                 selection: $selection, pressing: $pressing)

                // 2) Видимые подписи поверх — тапы проходят сквозь к подложке.
                HStack(spacing: 0) {
                    ForEach(titles.indices, id: \.self) { i in
                        Text(titles[i])
                            .font(.subheadline.weight(.semibold))
                            // Активный — чёрный на белой подсветке; при нажатии (стекло)
                            // и неактивный — белый.
                            .foregroundStyle(selection == i && !pressing ? Color.black : Color.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.9), value: selection)
                .animation(.easeOut(duration: 0.15), value: pressing)
                .allowsHitTesting(false)
            }
            .glassEffect(.regular.interactive(), in: .capsule)
        }
        .frame(height: height)
    }
}

/// Нативный UISegmentedControl с прозрачными заголовками — только ради родной
/// liquid-glass подсветки и обработки тапов; видимый текст рисует оверлей сверху.
private struct SegmentedBacking: UIViewRepresentable {

    var size: CGSize
    var count: Int
    @Binding var selection: Int
    @Binding var pressing: Bool

    func makeUIView(context: Context) -> UISegmentedControl {
        let control = UISegmentedControl(items: Array(repeating: "", count: count))
        control.selectedSegmentIndex = selection
        control.selectedSegmentTintColor = .white  // белая liquid-glass подсветка
        // Заголовки невидимы — подписи рисует SwiftUI-оверлей.
        let clear: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.clear]
        control.setTitleTextAttributes(clear, for: .normal)
        control.setTitleTextAttributes(clear, for: .selected)
        control.addTarget(context.coordinator,
                          action: #selector(Coordinator.changed(_:)),
                          for: .valueChanged)
        // Состояние нажатия — родные события UIControl (не конфликтуют со скроллом).
        control.addTarget(context.coordinator,
                          action: #selector(Coordinator.pressDown),
                          for: .touchDown)
        control.addTarget(context.coordinator,
                          action: #selector(Coordinator.pressUp),
                          for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
        return control
    }

    func updateUIView(_ uiView: UISegmentedControl, context: Context) {
        if uiView.selectedSegmentIndex != selection {
            uiView.selectedSegmentIndex = selection
        }
    }

    // Заполняем всю выделенную геометрию (высота 46pt задаётся снаружи через .frame).
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UISegmentedControl, context: Context) -> CGSize? {
        size
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject {
        let parent: SegmentedBacking
        init(_ parent: SegmentedBacking) { self.parent = parent }

        @objc func changed(_ sender: UISegmentedControl) {
            parent.selection = sender.selectedSegmentIndex
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }

        @objc func pressDown() { parent.pressing = true }
        @objc func pressUp() { parent.pressing = false }
    }
}
