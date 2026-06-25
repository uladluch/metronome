//
//  BPMSheet.swift
//  animations for metronome
//
//  Шит ввода BPM (правая кнопка нижнего тулбара). На весь экран (.large),
//  системный тулбар: крестик слева, чек (белый) справа, тайтл «BPM».
//  Крупное редактируемое число (дефолт 90), автофокус + хаптик на клавиатуру.
//  Значение > 360 не вводится: shake + error-хаптик.
//

import SwiftUI

struct BPMSheet: View {

    @Environment(\.dismiss) private var dismiss

    @State private var bpmText: String = "90"
    @State private var lastValid: String = "90"
    @State private var shakes: CGFloat = 0
    @FocusState private var focused: Bool

    private let maxBPM = 360

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Крупное редактируемое значение по центру.
                TextField("", text: $bpmText)
                    .font(.system(size: 72, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .focused($focused)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                    .modifier(Shake(animatableData: shakes))
                    .onChange(of: bpmText) { _, newValue in
                        // Больше 360 — не даём ввести: возвращаем прошлое + ошибка.
                        if let v = Int(newValue), v > maxBPM {
                            bpmText = lastValid
                            triggerError()
                        } else {
                            lastValid = newValue
                        }
                    }

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
        .presentationDetents([.large])
        // Дать шиту открыться, затем фокус → клавиатура + хаптик на её появление.
        .task {
            try? await Task.sleep(for: .milliseconds(350))
            focused = true
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
    }

    /// Ошибка ввода: «рычащий» error-хаптик + быстрый shake поля.
    private func triggerError() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        withAnimation(.linear(duration: 0.25)) { shakes += 1 }
    }
}

// MARK: - Shake-эффект

private struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit: CGFloat = 4
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(translationX: amount * sin(animatableData * .pi * shakesPerUnit),
                              y: 0)
        )
    }
}
