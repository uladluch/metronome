//
//  BPMSheet.swift
//  animations for metronome
//
//  Контент BPM-шита перенесён ИНЛАЙН в BottomReadme: отдельная struct-вью с
//  TextField ломала нативный sheet — он «улетал» вверх при появлении клавиатуры
//  (известный баг UISheetPresentationController, см. Apple Dev Forums #743274).
//  Инлайн-контент + .ignoresSafeArea(.keyboard) держит высоту фиксированной.
//

import SwiftUI
