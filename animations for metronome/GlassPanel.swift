//
//  GlassPanel.swift
//  animations for metronome
//
//  Модальные панели из liquid glass с morphing.
//

import SwiftUI

enum PanelPosition {
    case left
    case right
    case center
}

struct GlassPanel: View {

    let position: PanelPosition
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            // Полупрозрачная подложка для закрытия панели
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }

            // Сама панель в зависимости от позиции
            VStack {
                HStack {
                    if position == .right {
                        Spacer()
                    }

                    // Контент панели
                    VStack(spacing: 20) {
                        Text(position == .left ? "Left Panel" : position == .right ? "Right Panel" : "Center Panel")
                            .foregroundStyle(.white)
                            .font(.headline)

                        Button("Close") {
                            withAnimation {
                                isPresented = false
                            }
                        }
                        .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .appGlass(in: RoundedRectangle(cornerRadius: 20), interactive: false)
                    .padding(20)

                    if position == .left {
                        Spacer()
                    }
                }

                Spacer()
            }
        }
    }
}
