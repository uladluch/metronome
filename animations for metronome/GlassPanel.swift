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

    /// Иконка-tile панели — совпадает с иконкой её кнопки в тулбаре.
    var icon: String {
        switch self {
        case .left:   return "gearshape"
        case .right:  return "ellipsis"
        case .center: return "metronome"
        }
    }
}

struct GlassPanel: View {

    let position: PanelPosition
    let namespace: Namespace.ID
    let morphProgress: CGFloat
    let onClose: () -> Void

    var body: some View {
        let _ = print("[GlassPanel] Rendering \(position) panel, morphProgress: \(morphProgress)")

        // Stage 2 progress: нормализуем 0.5→1 в 0→1.
        let stage2Progress = max((morphProgress - 0.5) * 2, 0)

        // Opacity панели: 0 при progress < 0.5, потом растёт к 1.
        let panelOpacity = stage2Progress

        // cornerRadius: начинаем с овала (0) и переходим к 35 на stage 2.
        let cornerRadius = stage2Progress * 35

        return VStack(spacing: 24) {
            // Только крестик справа (title и icon только для center/right).
            HStack {
                if position != .left {
                    Image(systemName: position.icon)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.white)

                    Text(position.title)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }

                Spacer()

                GlassButton(shape: Circle(), namespace: namespace, action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                }
            }

            Spacer()
        }
        .padding(24)
        // Ширина = контейнер минус 16pt по каждому боку, высота — половина экрана,
        // прижато к верху и отцентрировано по горизонтали.
        .containerRelativeFrame([.horizontal, .vertical], alignment: .top) { length, axis in
            axis == .vertical ? length / 2 : length - 32
        }
        // Стекло с progress-controlled cornerRadius.
        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: max(0, cornerRadius)))
        .glassEffectID(position.glassID, in: namespace)
        .opacity(panelOpacity)
        .animation(.spring(response: 0.55, dampingFraction: 0.78), value: morphProgress)
    }

