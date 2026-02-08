//
//  ContentView.swift
//  Yena's Fit Studio
//
//  Created on 2026-02-08.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("홈", systemImage: "house.fill")
                }
                .tag(0)
            
            if let currentProject = dataManager.currentProject {
                DesignWorkspaceView(project: currentProject)
                    .tabItem {
                        Label("작업", systemImage: "paintbrush.fill")
                    }
                    .tag(1)
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DataManager())
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
#endif
