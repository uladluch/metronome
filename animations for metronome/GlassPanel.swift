//
//  GlassPanel.swift
//  animations for metronome
//
//  Модальная панель из Liquid Glass, в которую морфит кнопка тулбара.
//  Панель несёт тот же glassEffectID, что и её кнопка, и живёт в том же
//  GlassEffectContainer — за счёт этого стекло «перетекает» кнопка ⇄ панель.
//

import SwiftUI

enum PanelPosition {
    case left
    case right
    case center

    /// Якорь морфинга — общий для кнопки и её панели.
    var glassID: String {
        switch self {
        case .left:   return "panel.left"
        case .right:  return "panel.right"
        case .center: return "panel.center"
        }
    }

    /// Где панель прикрепляется по горизонтали (морфит из своей кнопки).
    var alignment: Alignment {
        switch self {
        case .left:   return .topLeading
        case .right:  return .topTrailing
        case .center: return .top
        }
    }

    var width: CGFloat {
        switch self {
        case .center: return 300
        case .left, .right: return 260
        }
    }

    var title: String {
        switch self {
        case .left:   return "Left Panel"
        case .right:  return "Right Panel"
        case .center: return "Center Panel"
        }
    }
}

struct GlassPanel: View {

    let position: PanelPosition
    let namespace: Namespace.ID
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(position.title)
                .font(.headline)
                .foregroundStyle(.white)

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .appGlass(in: .circle, interactive: true)
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .frame(width: position.width, height: 320)
        .appGlass(in: RoundedRectangle(cornerRadius: 28), interactive: true)
        .glassEffectID(position.glassID, in: namespace)
        // Прижимаем панель к стороне её кнопки.
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: position.alignment)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}
