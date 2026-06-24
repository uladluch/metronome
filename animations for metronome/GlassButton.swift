//
//  GlassButton.swift
//  animations for metronome
//
//  Единая стеклянная кнопка для всего приложения: стекло + «полусфера» ПОД ним
//  (в верхнем левом углу) + лёгкий inner shadow сверху + подсветка на нажатии.
//  Форма любая (circle / capsule / rounded rect) — передаётся параметром.
//

import SwiftUI

struct GlassButton<Label: View>: View {

    private let shape: AnyShape
    private let glassID: String?
    private let namespace: Namespace.ID
    private let action: () -> Void
    private let label: Label

    @State private var isPressed = false

    init(
        shape: some Shape,
        glassID: String? = nil,
        namespace: Namespace.ID,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.shape = AnyShape(shape)
        self.glassID = glassID
        self.namespace = namespace
        self.action = action
        self.label = label()
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // «Полусфера» ПОД стеклом — фиксированный блик в верхнем левом углу.
            // Жёстко привязан к toplLeading контейнера, потом весь ZStack обрезается
            // по форме. Так сфера одинаково лежит на любой форме.
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(isPressed ? 0.24 : 0.12),
                            .white.opacity(0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 26
                    )
                )
                .frame(width: 52, height: 52)
                .offset(x: -6, y: -6)
                .animation(.easeOut(duration: 0.22), value: isPressed)
                .onAppear {
                    print("[GlassButton] \(String(describing: shape)): sphere positioned at topLeading, offset(-6,-6)")
                }

            // Стекло поверх полусферы.
            label
                .appGlass(in: shape, interactive: true)
                .glassMorphID(glassID, in: namespace)
        }
        // Весь ZStack обрезается по форме кнопки.
        .clipShape(shape)
        .onAppear {
            print("[GlassButton] ClipShape: \(String(describing: shape))")
        }
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
        .onTapGesture(perform: action)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        withAnimation(.easeOut(duration: 0.12)) { isPressed = true }
                        print("[GlassButton] Press: isPressed=true")
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.3)) { isPressed = false }
                    print("[GlassButton] Release: isPressed=false")
                }
        )
        .accessibilityAddTraits(.isButton)
    }
}
