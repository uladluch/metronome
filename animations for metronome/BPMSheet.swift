//
//  BPMSheet.swift
//  animations for metronome
//
//  Шит ввода BPM (правая кнопка нижнего тулбара). Компактный, высота 200pt —
//  клавиатура двигает его как обычно, фон приложения сзади виден (без скрима).
//  Системный тулбар: крестик слева, «Save» справа, без тайтла. Крупное число
//  (дефолт 90), автофокус + хаптик. Курсор скрыт, фон — сплошной #1C1C1C.
//  Свайп вниз закрывает шит целиком.
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
                    .tint(.clear)               // убираем мигающий курсор (caret)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)

                Spacer()
            }
            // Свайп вниз по шиту закрывает его ЦЕЛИКОМ (а не просто прячет клавиатуру).
            // highPriorityGesture — чтобы перебить системный «свайп = убрать клавиатуру»;
            // срабатываем по ходу свайпа (onChanged), как только ушли на 40pt вниз.
            .contentShape(Rectangle())
            .highPriorityGesture(
                DragGesture(minimumDistance: 15)
                    .onChanged { value in
                        if value.translation.height > 40,
                           abs(value.translation.width) < value.translation.height {
                            focused = false
                            dismiss()
                        }
                    }
            )
            .navigationTitle("")
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
                // Чек справа — обычное стекло, как крестик (без tint/prominent).
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        // Превышение лимита — сообщаем наружу (нотификация после закрытия).
                        if let v = Int(bpmText), v > maxBPM {
                            onExceedMax()
                        }
                        dismiss()
                    }) {
                        Text("Save")
                    }
                }
            }
        }
        // Компактный шит фиксированной высоты — клавиатура двигает его как обычно.
        // Маленький детент → фон приложения сзади виден (фишка).
        .presentationDetents([.height(200)])
        // Убираем затемняющий скрим (в т.ч. когда выезжает клавиатура): фон остаётся
        // интерактивным и не темнеет.
        .presentationBackgroundInteraction(.enabled)
        // Фон шита — сплошной вторичный (#1C1C1C).
        .presentationBackground(Color.backgroundSecondary)
        // Тонкая обводка по краю шита.
        .sheetHairlineBorder()
        // Граббер сверху.
        .presentationDragIndicator(.visible)
        // Клавиатура не должна менять высоту контента шита.
        .ignoresSafeArea(.keyboard, edges: .bottom)
        // Фокус СРАЗУ при появлении — клавиатура поднимается ОДНОВРЕМЕННО с презентацией
        // шита (одно движение, шит сразу появляется в поднятой позиции), а не «в два
        // яруса» (маленький шит → потом клавиатура его выталкивает).
        .task {
            focused = true
        }
        // Хаптик именно в момент появления клавиатуры (а не на фокус).
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
    }
}
