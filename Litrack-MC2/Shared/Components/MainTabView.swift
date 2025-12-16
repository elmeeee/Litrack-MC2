//
//  MainTabView.swift
//  Litrack-MC2
//
//  Main Tab Navigation Component
//  Copyright © 2024 Litrack Team. All rights reserved.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background Gradient
            LinearGradient(
                colors: [
                    Color(hex: "0F2027"),
                    Color(hex: "203A43"),
                    Color(hex: "2C5364")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Tab Content
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)
                
                HistoryView()
                    .tag(1)
                
                AnalyticsView()
                    .tag(2)
                
                SettingsView()
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
        }
        .fullScreenCover(isPresented: $appState.showCamera) {
            CameraView()
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
        .environment(\.managedObjectContext, DataController.shared.container.viewContext)
}
