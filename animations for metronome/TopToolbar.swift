//
//  TopToolbar.swift
//  animations for metronome
//
//  Верхний тулбар: левая и правая стеклянные кнопки 60×60
//  и центральная стеклянная капсула 180×60.
//

import SwiftUI

struct TopToolbar: View {

    let onLeftTap: () -> Void
    let onRightTap: () -> Void
    let onCenterTap: () -> Void

    private let leftIcon = "gearshape"
    private let rightIcon = "ellipsis"

    var body: some View {
        GlassEffectContainer(spacing: 16) {
            HStack(spacing: 0) {
                ToolbarIconButton(systemName: leftIcon, action: onLeftTap)

                Spacer(minLength: 0)

                Button(action: onCenterTap) {
                    Color.clear
                        .frame(width: 180, height: 60)
                        .appGlass(in: .capsule, interactive: true)
                }
                .buttonStyle(.plain)

                Spacer(minLength: 0)

                ToolbarIconButton(systemName: rightIcon, action: onRightTap)
            }
        }
    }
}

// MARK: - Кнопка тулбара

/// Стеклянная кнопка 60×60 с белой SF-иконкой по центру.
private struct ToolbarIconButton: View {

    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .appGlass(in: .circle, interactive: true)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        VStack {
            TopToolbar(
                onLeftTap: { },
                onRightTap: { },
                onCenterTap: { }
            )
            .padding(.horizontal, 16)
            Spacer()
        }
    }
    .preferredColorScheme(.dark)
}
