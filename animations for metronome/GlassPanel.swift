//
//  GlassPanel.swift
//  animations for metronome
//
//  Внутренний контент панели, который раскрывается из шестерёнки через
//  ExpandableGlassMenu. Стекло/форму/морф даёт сам ExpandableGlassMenu —
//  здесь только содержимое (заголовок, строки, крестик).
//

import SwiftUI

struct PanelContent: View {

    var onClose: () -> Void

    private let rows = ["Tempo", "Sound", "Vibration"]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("Settings")
                    .font(.title.bold())
                    .foregroundStyle(.white)

                Spacer()

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.white.opacity(0.18)))
                }
                .buttonStyle(.plain)
            }

            ForEach(rows, id: \.self) { item in
                HStack {
                    Text(item)
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(.vertical, 10)
            }

            Spacer()
        }
        .padding(28)
    }
}
