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
        self.label = label()
    }

    private var domeOpacity: Double {
        isPressed ? 0.24 : 0.12
    }

    var body: some View {
        label
            .glassEffect(glassStyle.interactive(), in: shape)
            .glassMorphID(glassID, in: namespace)
            // Полусфера (блик) ПОД стеклом, масштабируется под размер кнопки.
            .background(alignment: .topLeading) {
                if showDome {
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
            .overlay {
                shape
                    .stroke(Color.white.opacity(0.22), lineWidth: 5)
                    .blur(radius: 7)
                    .offset(y: 3)
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
            .accessibilityAddTraits(.isButton)
            // Увеличение на нажатие (pressScale, 1.0 = выкл).
            .scaleEffect(isPressed ? pressScale : 1.0)
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
