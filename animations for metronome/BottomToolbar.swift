//
//  BottomToolbar.swift
//  animations for metronome
//
//  Нижний тулбар: по бокам такие же стеклянные кнопки 60×60, что и сверху,
//  а по центру — нативный SwiftUI Slider (вместо капсулы).
//  Кнопки-квадраты открывают нативный sheet с grabber'ом (свайпаемый).
//

import SwiftUI
import UIKit.UIGestureRecognizerSubclass  // для сеттера .state в кастомном распознавателе

struct BottomToolbar: View {

    // Кнопки тут не морфят, namespace нужен только для сигнатуры.
    @Namespace private var ns

    /// Открыть главный шит (тот же, что и верхние кнопки) — состояние живёт в ContentView.
    var onMainSheet: () -> Void = {}
    /// BPM превысил лимит — показать нотификацию (баннер живёт в ContentView).
    var onBPMOverflow: () -> Void = {}

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
                    showShine: true,
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
                    showShine: true,
                    action: { showBPM = true }
                )
            }
            .frame(height: 60)
            // Конкретная ширина = экран − 32 (по 16pt с боков), центр.
            .containerRelativeFrame(.horizontal) { length, _ in length - 32 }
        }
        // Уникальный шит — ввод BPM (нижняя правая кнопка). Пока на весь экран.
        .sheet(isPresented: $showBPM) {
            BPMSheet(onExceedMax: onBPMOverflow)
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
    /// Значение кастомного степпера.
    @State private var stepperValue = 5

    /// Верхний бар: тайтл 32pt слева + крестик справа, по центру по вертикали,
    /// высота 81pt. Без своего фона — системный scroll edge effect делает блюр сам.
    private var topBar: some View {
        ZStack {
            HStack {
                Spacer()
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .glassEffect(.regular.interactive(), in: Circle())
                }
                .buttonStyle(.plain)
            }
            HStack {
                Text("Sheet")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .frame(height: 81)
    }

    var body: some View {
        NavigationStack {
            Form {
                // Блок с сегментом сверху и контентом, который меняется по выбору.
                // Едет вместе со скроллом (не закреплён).
                Section("Segment control") {
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
                        Color.backgroundSecondary,
                        in: RoundedRectangle(cornerRadius: 28, style: .continuous)
                    )
                    // На всю ширину контейнера (без боковых insets) + внешний margin 16 сверху/снизу.
                    .listRowInsets(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                // Отдельная секция — кастомный степпер с LG-кнопками +/- в блоке,
                // как у segment control (карточка фона 3-го уровня).
                Section("Stepper") {
                    VStack(spacing: 16) {
                        GlassStepper(value: $stepperValue, range: 1...10)

                        // Контент блока под степпером.
                        Text("Value: \(stepperValue)")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 32)
                    .background(
                        Color.backgroundSecondary,
                        in: RoundedRectangle(cornerRadius: 28, style: .continuous)
                    )
                    .listRowInsets(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                // Строка-переход: пушит дочерний экран (слайд справа) с НАТИВНЫМ
                // тулбаром — «назад» слева (авто) + крестик справа. Граббер шита
                // сохраняется.
                Section("Navigation") {
                    NavigationLink {
                        SheetDetailView(onClose: { dismiss() })
                    } label: {
                        Text("Тапни на меня")
                    }
                }
                .listRowBackground(Color.backgroundSecondary)

                Section("Microanimations") {
                    // Toggle row
                    HStack {
                        Text("Toggle")
                        Spacer()
                        Toggle("", isOn: $toggleOn)
                            // Активный цвет светлее, чем у слайдеров (controlAccent).
                            .tint(Color(white: 0.7))
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
                .listRowBackground(Color.backgroundSecondary)

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
                .listRowBackground(Color.backgroundSecondary)
            }
            // Фон Form прозрачный — под ним общий чёрный фон шита.
            .scrollContentBackground(.hidden)
            .background(Color.backgroundPrimary)
            // Нативный scroll edge effect (iOS 26) сверху — мягкий (soft).
            .scrollEdgeEffectStyle(.soft, for: .top)
            // safeAreaBar (iOS 26) — в отличие от safeAreaInset, включает
            // прогрессивный scroll-edge блюр под кастомным баром.
            .safeAreaBar(edge: .top, spacing: 0) { topBar }
            // Системный нав-бар скрыт ТОЛЬКО на корне — свой бар выше. Граббер
            // даёт презентация. На дочернем экране бар снова нативный.
            .toolbar(.hidden, for: .navigationBar)
        }
        // Ширина контейнера для popover на всю ширину.
        .onGeometryChange(for: CGFloat.self, of: { $0.size.width }, action: { containerWidth = $0 })
    }
}

// MARK: - Детальный экран (нативный тулбар: назад + крестик)

/// Пушится из SheetView (дочерний экран). НАТИВНЫЙ топ-тулбар: «назад» слева
/// добавляется автоматически при push, крестик справа закрывает весь шит.
struct SheetDetailView: View {

    /// Закрыть весь шит (а не просто вернуться назад).
    var onClose: () -> Void

    var body: some View {
        Form {
            Section {
                Text("Detail screen with native toolbar.")
                    .foregroundStyle(.white)
            }
            .listRowBackground(Color.backgroundSecondary)
        }
        .scrollContentBackground(.hidden)
        .background(Color.backgroundPrimary)
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
        // Явная видимость бара на дочернем — лечит «прыжок» бара при push из
        // корня со скрытым нав-баром.
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            // Крестик справа — закрыть весь шит (назад слева — нативный, авто).
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onClose()
                }) {
                    Image(systemName: "xmark")
                }
            }
        }
    }
}

// MARK: - Кастомный степпер с LG-кнопками

/// Степпер: капсула-контейнер с белой обводкой, по краям — наши стеклянные
/// кнопки +/- (GlassIconButton), число по центру. Высота 46pt, на всю ширину.
struct GlassStepper: View {

    @Binding var value: Int
    var range: ClosedRange<Int> = 1...10
    var step: Int = 1

    @Namespace private var ns

    private var atMin: Bool { value <= range.lowerBound }
    private var atMax: Bool { value >= range.upperBound }

    var body: some View {
        HStack(spacing: 0) {
            GlassIconButton(
                systemName: "minus",
                glassID: nil,
                namespace: ns,
                size: 44,
                iconSize: 20,
                repeatAction: { change(-step) },
                showShine: true,
                action: { change(-step) }
            )
            // Чёрная подложка под самый низ — стекло над ней читается чёрным,
            // как у +/- возле скролла (переиспользуем тот же GlassIconButton 1:1).
            .background(Circle().fill(.black))
            .opacity(atMin ? 0.3 : 1)       // дизейбл на минимуме
            .disabled(atMin)

            Spacer(minLength: 0)

            Text("\(value)")
                .font(.headline)
                .foregroundStyle(.black)
                .contentTransition(.numericText())

            Spacer(minLength: 0)

            GlassIconButton(
                systemName: "plus",
                glassID: nil,
                namespace: ns,
                size: 44,
                iconSize: 20,
                repeatAction: { change(step) },
                showShine: true,
                action: { change(step) }
            )
            // Чёрная подложка под самый низ — стекло над ней читается чёрным.
            .background(Circle().fill(.black))
            .opacity(atMax ? 0.3 : 1)       // дизейбл на максимуме
            .disabled(atMax)
        }
        .padding(.horizontal, 2)
        .frame(width: 155, height: 46)
        // Белая заливка-капсула.
        .background(Color.white, in: Capsule())
    }

    private func change(_ delta: Int) {
        let next = min(max(value + delta, range.lowerBound), range.upperBound)
        guard next != value else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.snappy(duration: 0.2)) { value = next }
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
    /// Интерактивное стекло (блик) — только на лонг-пресс/перетягивание, не на тап.
    @State private var glassInteractive = false

    var body: some View {
        GlassEffectContainer(spacing: 10) {
            GeometryReader { geo in
                let segW = geo.size.width / CGFloat(max(titles.count, 1))
                ZStack(alignment: .leading) {
                    // 1) Нативная подложка: невидимые заголовки, СКРЫТАЯ подсветка —
                    //    только тапы/перетягивание/выбор и интерактивный блик.
                    SegmentedBacking(size: geo.size, count: titles.count,
                                     selection: $selection, pressing: $pressing,
                                     glassInteractive: $glassInteractive)

                    // 2) Своя белая «пилюля» — едет к выбранному сегменту с МЯГКОЙ,
                    //    настраиваемой пружиной (вместо нативного резкого баунса).
                    Capsule()
                        .fill(.white)
                        .padding(3)
                        .frame(width: segW)
                        .offset(x: segW * CGFloat(selection))
                        .allowsHitTesting(false)
                        // На лонг-прессе (появился LG) прячем белую плашку — её
                        // возвращаем только после выхода из фокуса (отпускания).
                        .opacity(glassInteractive ? 0 : 1)
                        .animation(.spring(response: 0.38, dampingFraction: 0.9), value: selection)
                        .animation(.easeOut(duration: 0.18), value: glassInteractive)

                    // 3) Видимые подписи поверх — тапы проходят сквозь к подложке.
                    HStack(spacing: 0) {
                        ForEach(titles.indices, id: \.self) { i in
                            Text(titles[i])
                                .font(.subheadline.weight(.semibold))
                                // Чёрный только когда белая плашка под ним ВИДНА
                                // (активный, не нажат, плашка не скрыта). Иначе — белый:
                                // при нажатии или когда плашка спрятана под LG.
                                .foregroundStyle(
                                    selection == i && !pressing && !glassInteractive
                                        ? Color.black : Color.white
                                )
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    // Цвет подписи плавно перетекает в такт пилюле (по selection);
                    // pressing меняет цвет мгновенно (этим модификатором не анимируется).
                    .animation(.spring(response: 0.38, dampingFraction: 0.9), value: selection)
                    .allowsHitTesting(false)
                }
                // Блик (.interactive) — только на лонг-пресс/перетягивание; на
                // обычный тап-переключение стекло обычное, без сияния.
                .glassEffect(glassInteractive ? .regular.interactive() : .regular, in: .capsule)
            }
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
    @Binding var glassInteractive: Bool

    func makeUIView(context: Context) -> UISegmentedControl {
        let control = UISegmentedControl(items: Array(repeating: "", count: count))
        control.selectedSegmentIndex = selection
        // Нативную подсветку прячем — её рисует своя SwiftUI-пилюля (мягкий баунс).
        control.selectedSegmentTintColor = .clear
        // Заголовки невидимы — подписи рисует SwiftUI-оверлей.
        let clear: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.clear]
        control.setTitleTextAttributes(clear, for: .normal)
        control.setTitleTextAttributes(clear, for: .selected)
        control.addTarget(context.coordinator,
                          action: #selector(Coordinator.changed(_:)),
                          for: .valueChanged)
        // Состояние нажатия. UISegmentedControl НЕ шлёт надёжно touchDown/touchUp
        // таргетам, а UILongPressGestureRecognizer выдаёт .began с задержкой.
        // Кастомный TouchDownGesture ставит .began прямо в touchesBegan → реакция
        // моментальная. cancelsTouchesInView=false + одновременное распознавание →
        // не мешает ни переключению, ни скроллу Form.
        let press = TouchDownGesture(
            target: context.coordinator,
            action: #selector(Coordinator.pressed(_:))
        )
        press.cancelsTouchesInView = false
        // По умолчанию распознаватель задерживает доставку касаний контролу, из-за
        // чего нативный drag-select не коммитится и подсветка отскакивает. Отключаем.
        press.delaysTouchesBegan = false
        press.delaysTouchesEnded = false
        press.delegate = context.coordinator
        control.addGestureRecognizer(press)
        return control
    }

    func updateUIView(_ uiView: UISegmentedControl, context: Context) {
        context.coordinator.parent = self  // держим биндинги/значения свежими
        // Во время жеста НЕ переписываем selectedSegmentIndex — иначе writeback
        // посреди нативного перетягивания сбивает drag и подсветка отскакивает.
        guard !context.coordinator.interacting else { return }
        if uiView.selectedSegmentIndex != selection {
            uiView.selectedSegmentIndex = selection
        }
    }

    // Заполняем всю выделенную геометрию (высота 46pt задаётся снаружи через .frame).
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UISegmentedControl, context: Context) -> CGSize? {
        size
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var parent: SegmentedBacking
        /// Жест начался на активном сегменте — тогда держим белый весь жест,
        /// включая перетягивание подсветки к другому сегменту (иначе исходный
        /// мигнул бы чёрным, пока selection ещё не переключился).
        private var startedOnActive = false
        /// Момент касания — чтобы гарантировать минимально видимое время белого
        /// (быстрый тап иначе схлопывается и белый кадр не успевает отрисоваться).
        private var pressStart = Date()
        private let minWhite: TimeInterval = 0.18
        /// Отложенное включение интерактивного стекла (порог лонг-пресса).
        private var glassWork: DispatchWorkItem?
        private let longPressThreshold: TimeInterval = 0.2
        /// Идёт ли касание/перетягивание — на это время не переписываем selection
        /// обратно в контрол (иначе сбивается нативный drag).
        private(set) var interacting = false
        init(_ parent: SegmentedBacking) { self.parent = parent }

        @objc func changed(_ sender: UISegmentedControl) {
            parent.selection = sender.selectedSegmentIndex
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }

        @objc func pressed(_ g: UIGestureRecognizer) {
            guard let control = g.view as? UISegmentedControl else { return }
            switch g.state {
            case .began:
                interacting = true
                let segW = control.bounds.width / CGFloat(max(control.numberOfSegments, 1))
                let idx = Int(g.location(in: control).x / segW)
                startedOnActive = (idx == control.selectedSegmentIndex)
                // Моментально белим, если нажали на активный сегмент (тап и
                // удержание одинаково) — без задержки.
                pressStart = Date()
                parent.pressing = startedOnActive
                // Интерактивное стекло — только если удержание затянулось (лонг-пресс),
                // на обычный тап-переключение блик не показываем.
                glassWork?.cancel()
                let gw = DispatchWorkItem { [weak self] in self?.parent.glassInteractive = true }
                glassWork = gw
                DispatchQueue.main.asyncAfter(deadline: .now() + longPressThreshold, execute: gw)
            case .changed:
                break  // pressing держится с .began до .ended (в т.ч. при перетягивании)
            case .ended, .cancelled, .failed:
                let wasActive = startedOnActive
                startedOnActive = false
                glassWork?.cancel()  // не успел лонг-пресс — блик не включаем
                // selection синкаем с контролом и снимаем interacting/стекло сразу
                // (после коммита, в следующем тике), а вот СНЯТИЕ белого держим минимум
                // minWhite от касания — иначе быстрый тап схлопывается и белого не видно.
                DispatchQueue.main.async {
                    self.parent.selection = control.selectedSegmentIndex
                    self.interacting = false
                    self.parent.glassInteractive = false
                    if !wasActive { self.parent.pressing = false }
                }
                if wasActive {
                    let remaining = max(0, minWhite - Date().timeIntervalSince(pressStart))
                    DispatchQueue.main.asyncAfter(deadline: .now() + remaining) {
                        self.parent.pressing = false
                    }
                }
            default:
                break
            }
        }

        // Распознаём одновременно с внутренними жестами сегмента и скроллом —
        // не блокируем переключение/прокрутку.
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
            true
        }
    }
}

/// Распознаватель, который срабатывает МОМЕНТАЛЬНО по касанию: ставит .began прямо
/// в touchesBegan (в отличие от UILongPressGestureRecognizer, который медлит).
private final class TouchDownGesture: UIGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        state = .began
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        state = .changed
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        state = .ended
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        state = .cancelled
    }
}
