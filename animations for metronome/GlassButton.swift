//
//  GlassButton.swift
//  animations for metronome
//
//  Единая стеклянная кнопка для всего приложения: чистый нативный Liquid Glass
//  с interactive-откликом. Никаких доп. эффектов (dome/shine/inner-shadow) — только
//  стекло + жест. Форма любая (circle / capsule / rounded rect) — параметром.
//

import SwiftUI

struct GlassButton<Label: View>: View {

    private let shape: AnyShape
    private let glassID: String?
    private let namespace: Namespace.ID
    private let action: () -> Void
    private let repeatAction: (() -> Void)?
    private let label: Label
    private let glassStyle: Glass

    @State private var isPressed = false
    @State private var repeatTimer: Timer?
    @State private var didRepeat = false

    init(
        shape: some Shape,
        glassID: String? = nil,
        namespace: Namespace.ID,
        action: @escaping () -> Void,
        repeatAction: (() -> Void)? = nil,  // long-press авто-повтор
        glassStyle: Glass = AppGlass.style,
        @ViewBuilder label: () -> Label
    ) {
        self.shape = AnyShape(shape)
        self.glassID = glassID
        self.namespace = namespace
        self.action = action
        self.repeatAction = repeatAction
        self.glassStyle = glassStyle
        self.label = label()
    }

    var body: some View {
        label
            // Чистое нативное стекло с interactive-откликом — и всё.
            .glassEffect(glassStyle.interactive(), in: shape)
            .glassMorphID(glassID, in: namespace)
            .contentShape(shape)
            .onTapGesture {
                // Если был long-press авто-повтор — лишний шаг по тапу не делаем.
                if didRepeat { didRepeat = false; return }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                action()
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            startRepeat()
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        stopRepeat()
                    }
            )
            .accessibilityAddTraits(.isButton)
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
