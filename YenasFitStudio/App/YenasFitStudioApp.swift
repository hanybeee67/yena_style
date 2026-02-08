//
//  YenasFitStudioApp.swift
//  Yena's Fit Studio
//
//  Created on 2026-02-08.
//  AI 기반 패션 디자인 & 패턴 제작 iPad 앱
//

import SwiftUI

@main
struct YenasFitStudioApp: App {
    @StateObject private var dataManager = DataManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
        }
    }
}
