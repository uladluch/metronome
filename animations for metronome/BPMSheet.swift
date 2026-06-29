//
//  BPMSheet.swift
//  animations for metronome
//
//  Шит ввода BPM (правая кнопка нижнего тулбара). На весь экран (.large),
//  системный тулбар: крестик слева, чек (белый) справа, тайтл «BPM».
//  Крупное редактируемое число (дефолт 90), автофокус + хаптик на клавиатуру.
//  Ввод любого значения разрешён; если при подтверждении > 360 — после закрытия
//  показываем нотификацию (через onExceedMax → ContentView).
//

import SwiftUI

struct BPMSheet: View {

    @Environment(\.dismiss) private var dismiss

    @State private var bpmText: String = "90"
    @FocusState private var focused: Bool

    private let maxBPM = 360

    /// Вызывается при подтверждении, если введённое значение превышает maxBPM.
    var onExceedMax: () -> Void = {}

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Крупное редактируемое значение по центру. Вводить можно что угодно.
                TextField("", text: $bpmText)
                    .font(.system(size: 72, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .focused($focused)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)

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
                        // Превышение лимита — сообщаем наружу (нотификация после закрытия).
                        if let v = Int(bpmText), v > maxBPM {
                            onExceedMax()
                        }
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
        // Дать шиту открыться, затем фокус → клавиатура (200ms).
        .task {
            try? await Task.sleep(for: .milliseconds(200))
            focused = true
        }
        // Хаптик именно в момент появления клавиатуры (а не на фокус).
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
    }
}
