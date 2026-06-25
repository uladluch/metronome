//
//  BPMSheet.swift
//  animations for metronome
//
//  Шит ввода BPM (правая кнопка нижнего тулбара). Высота 2/3 экрана, системный
//  тулбар: крестик слева (отмена), чек справа (подтвердить), тайтл «BPM» по центру.
//  Крупное редактируемое число; после появления — автофокус и клавиатура.
//

import SwiftUI

struct BPMSheet: View {

    @Environment(\.dismiss) private var dismiss

    @State private var bpmText: String = "96"
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Крупное значение (large title), редактируется, по центру.
                TextField("", text: $bpmText)
                    .font(.system(size: 64, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .focused($focused)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 32)

                Spacer()
            }
            .navigationTitle("BPM")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Крестик слева — отмена.
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                    }
                }
                // Чек справа — белая prominent-кнопка, чёрная иконка.
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        dismiss()
                    }) {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.black)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.white)
                }
            }
        }
        // Клавиатура не растит/не двигает шит (на весь NavigationStack).
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .presentationDetents([.fraction(2.0 / 3.0)])
        .presentationDragIndicator(.visible)
        // Сплошной фон как у large-шита (не Liquid Glass middle-стиль).
        .presentationBackground(Color(.systemBackground))
        // Дать шиту выехать, затем фокус → клавиатура.
        .task {
            try? await Task.sleep(for: .milliseconds(350))
            focused = true
        }
    }
}
