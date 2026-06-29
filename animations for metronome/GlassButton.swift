//
//  GlassButton.swift
//  animations for metronome
//
//  Единая стеклянная кнопка для всего приложения: стекло + «полусфера» ПОД ним
//  (в верхнем левом углу) + лёгкий inner shadow сверху + подсветка на нажатии.
//  Форма любая (circle / capsule / rounded rect) — передаётся параметром.
//  Dome масштабируется под размер кнопки (не ломает мелкие кнопки).
//

import SwiftUI

struct GlassButton<Label: View>: View {

    private let shape: AnyShape
    private let glassID: String?
    private let namespace: Namespace.ID
    private let action: () -> Void
    private let repeatAction: (() -> Void)?
    private let label: Label
    private let showDome: Bool
    private let pressScale: CGFloat
    private let glassStyle: Glass
    private let showShine: Bool
    private let shineImage: String
    private let shineOpacity: Double
    private let shineHorizontalOnly: Bool
    /// Явный размер блика (доля от размера кнопки). Если оба заданы — блик может
    /// вылезать за края и обрезается формой. nil — прежний scaledToFit.
    private let shineWidthFactor: CGFloat?
    private let shineHeightFactor: CGFloat?
    /// Внешнее «нажатие» для блика (когда жест живёт снаружи, как в StepZone).
    private let shineForcePressed: Bool
    /// Тип dome: true = радиальная полусфера в углу (для кругов), false = линейный градиент сверху (для капсул).
    private let domeAsRadial: Bool
    /// Зум на нажатие только по горизонтали (высота не меняется).
    private let pressScaleHorizontalOnly: Bool
    /// Внешний владелец сам применяет зум (например, к GlassEffectContainer снаружи) —
    /// тогда GlassButton НЕ масштабирует себя сам, но всё равно компенсирует текст.
    private let externalPressScale: Bool
    /// Сообщает наружу о смене состояния нажатия (для внешнего зума).
    private let onPressedChange: ((Bool) -> Void)?

    @Environment(\.isEnabled) private var isEnabled
    @State private var isPressed = false
    @State private var touchPoint: CGPoint = .zero
    @State private var repeatTimer: Timer?
    @State private var didRepeat = false

    init(
        shape: some Shape,
        glassID: String? = nil,
        namespace: Namespace.ID,
        action: @escaping () -> Void,
        repeatAction: (() -> Void)? = nil,  // long-press авто-повтор
        showDome: Bool = true,
        pressScale: CGFloat = 1.0,          // 1.0 = без увеличения на нажатие
        glassStyle: Glass = AppGlass.style,
        showShine: Bool = false,            // блик Shine под пальцем (под стеклом)
        shineImage: String = "Shine",       // имя ассета блика
        shineOpacity: Double = 0.1,          // прозрачность блика на нажатии
        shineHorizontalOnly: Bool = false,   // блик едет только по горизонтали
        shineWidthFactor: CGFloat? = nil,    // явный размер блика (доля ширины кнопки)
        shineHeightFactor: CGFloat? = nil,   // явный размер блика (доля высоты кнопки)
        shineForcePressed: Bool = false,     // внешнее «нажатие» для блика
        domeAsRadial: Bool = true,           // true = радиальная сфера (для кругов), false = линейный градиент (для капсул)
        pressScaleHorizontalOnly: Bool = false, // зум на нажатие только по ширине
        externalPressScale: Bool = false,    // зум применяет внешний владелец (контейнер)
        onPressedChange: ((Bool) -> Void)? = nil, // уведомление о нажатии наружу
        @ViewBuilder label: () -> Label
    ) {
        self.shape = AnyShape(shape)
        self.glassID = glassID
        self.namespace = namespace
        self.action = action
        self.repeatAction = repeatAction
        self.showDome = showDome
        self.pressScale = pressScale
        self.glassStyle = glassStyle
        self.showShine = showShine
        self.shineImage = shineImage
        self.shineOpacity = shineOpacity
        self.shineHorizontalOnly = shineHorizontalOnly
        self.shineWidthFactor = shineWidthFactor
        self.shineHeightFactor = shineHeightFactor
        self.shineForcePressed = shineForcePressed
        self.domeAsRadial = domeAsRadial
        self.pressScaleHorizontalOnly = pressScaleHorizontalOnly
        self.externalPressScale = externalPressScale
        self.onPressedChange = onPressedChange
        self.label = label()
    }

    private var domeOpacity: Double {
        isPressed ? 0.24 : 0.12
    }

    var body: some View {
        label
            // Когда зум только по горизонтали — компенсируем растяжение самого
            // контента (текста), чтобы тянулась капсула, а буквы не «толстели».
            .scaleEffect(
                x: (pressScaleHorizontalOnly && isPressed) ? 1.0 / pressScale : 1.0,
                y: 1.0
            )
            .glassEffect(glassStyle.interactive(), in: shape)
            .glassMorphID(glassID, in: namespace)
            // Полусфера (блик) ПОД стеклом, масштабируется под размер кнопки.
            .background {
                if showDome {
                    if domeAsRadial {
                        // Радиальная полусфера в верхнем левом углу (для круглых кнопок).
                        GeometryReader { g in
                            let s = min(g.size.width, g.size.height)
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [.white.opacity(domeOpacity), .white.opacity(0)],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: s * 0.43
                                    )
                                )
                                .frame(width: s * 0.87, height: s * 0.87)
                                .offset(x: -s * 0.1, y: -s * 0.1)
                                .animation(.easeOut(duration: 0.22), value: isPressed)
                        }
                    } else {
                        // Тот же приём, что и для круга: градиент, ОБРЕЗАННЫЙ формой
                        // кнопки. Для вытянутой капсулы свет ловится не точкой, а вдоль
                        // верхней кромки — поэтому градиент сверху-вниз, повторяющий
                        // изгиб капсулы. Падение яркости совпадает со сферой (~0.7 высоты).
                        GeometryReader { _ in
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        stops: [
                                            .init(color: .white.opacity(domeOpacity), location: 0),
                                            .init(color: .white.opacity(domeOpacity * 0.5), location: 0.35),
                                            .init(color: .white.opacity(0), location: 0.72)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .animation(.easeOut(duration: 0.22), value: isPressed)
                        }
                    }
                }
            }
            // Shine — нижний слой ПОД стеклом, едет под пальцем; виден на нажатии.
            // Стекло сверху его подсвечивает/преломляет. Обрезается shape ниже.
            .background {
                if showShine {
                    GeometryReader { g in
                        Group {
                            if let wf = shineWidthFactor, let hf = shineHeightFactor {
                                // Явный размер — может вылезать за края (обрежет shape).
                                Image(shineImage)
                                    .resizable()
                                    .frame(width: g.size.width * wf, height: g.size.height * hf)
                            } else {
                                Image(shineImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: g.size.height * 2.2)
                            }
                        }
                            .position(
                                x: touchPoint == .zero ? g.size.width / 2 : touchPoint.x,
                                // Если только по горизонтали — Y фиксируем по центру.
                                y: (shineHorizontalOnly || touchPoint == .zero)
                                    ? g.size.height / 2 : touchPoint.y
                            )
                            // Почти прозрачный — лёгкое свечение под стеклом.
                            .opacity((isPressed || shineForcePressed) ? shineOpacity : 0)
                            .animation(.easeOut(duration: 0.4), value: isPressed)
                            .animation(.easeOut(duration: 0.4), value: shineForcePressed)
                            // Плавно доезжает за пальцем (медленнее, больше рассеивает).
                            .animation(.easeOut(duration: 0.55), value: touchPoint)
                            .allowsHitTesting(false)
                    }
                }
            }
            .clipShape(shape)
            // Лёгкая имитация inner shadow — белый блик по верхней кромке.
            // Толщина/размытие/сдвиг масштабируются от размера кнопки (эталон 60pt:
            // 5 / 7 / 3), иначе на маленьких +/- (44pt) блик выглядит непропорционально
            // толстым по сравнению с основными кнопками.
            .overlay {
                GeometryReader { g in
                    let s = min(g.size.width, g.size.height)
                    shape
                        .stroke(Color.white.opacity(0.22), lineWidth: s * 0.083)
                        .blur(radius: s * 0.117)
                        .offset(y: s * 0.05)
                        .mask(
                            shape.fill(
                                LinearGradient(
                                    colors: [.white, .clear],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                        )
                }
            }
            .contentShape(shape)
            .onTapGesture {
                // Если был long-press авто-повтор — лишний шаг по тапу не делаем.
                if didRepeat { didRepeat = false; return }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                action()
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        touchPoint = value.location  // Shine едет под пальцем
                        if !isPressed {
                            withAnimation(.easeOut(duration: 0.12)) { isPressed = true }
                            startRepeat()
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.easeOut(duration: 0.3)) { isPressed = false }
                        stopRepeat()
                    }
            )
            // Кнопка стала disabled (например, степпер достиг предела) во время
            // удержания — SwiftUI отменяет жест без onEnded, поэтому глушим
            // авто-повтор сами, иначе таймер «залипает» и дёргает action.
            .onChange(of: isEnabled) { _, enabled in
                if !enabled {
                    stopRepeat()
                    didRepeat = false
                    withAnimation(.easeOut(duration: 0.2)) { isPressed = false }
                }
            }
            .accessibilityAddTraits(.isButton)
            // Увеличение на нажатие (pressScale, 1.0 = выкл).
            // Если pressScaleHorizontalOnly — растягиваем только по ширине, высота прежняя.
            // Если externalPressScale — зум применяет внешний владелец (контейнер), сами не масштабируем.
            .scaleEffect(
                x: (!externalPressScale && isPressed) ? pressScale : 1.0,
                y: (!externalPressScale && isPressed) ? (pressScaleHorizontalOnly ? 1.0 : pressScale) : 1.0
            )
            // Сообщаем наружу о нажатии (для внешнего зума контейнера).
            .onChange(of: isPressed) { _, pressed in
                onPressedChange?(pressed)
            }
    }

    // MARK: - Long-press авто-повтор

    private func startRepeat() {
        guard repeatAction != nil else { return }
        didRepeat = false
        repeatTimer?.invalidate()
        // Сначала пауза (чтобы обычный тап не триггерил повтор), затем частые шаги.
        repeatTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { _ in
            didRepeat = true
            repeatAction?()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            repeatTimer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { _ in
                repeatAction?()
            }
        }
    }

    private func stopRepeat() {
        repeatTimer?.invalidate()
        repeatTimer = nil
    }
}
