//
//  GlassPanel.swift
//  animations for metronome
//
//  Полноэкранное окно из Liquid Glass, в которое морфит кнопка тулбара.
//  Окно несёт тот же glassEffectID, что и его кнопка, и живёт в том же
//  GlassEffectContainer — поэтому стекло «вытягивается» из кнопки на весь
//  контейнер и обратно. Origin морфинга определяется кадром кнопки-источника:
//  слева тянется слева, справа — справа, центр — из центра.
//

import SwiftUI

enum PanelPosition {
    case left
    case right
    case center

    /// Якорь морфинга — общий для кнопки и её окна.
    var glassID: String {
        switch self {
        case .left:   return "panel.left"
        case .right:  return "panel.right"
        case .center: return "panel.center"
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
        VStack(spacing: 24) {
            HStack {
                Text(position.title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Spacer()

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .padding(24)
        // Тянем окно на весь контейнер.
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .appGlass(in: RoundedRectangle(cornerRadius: 40), interactive: false)
        .glassEffectID(position.glassID, in: namespace)
    }
}
