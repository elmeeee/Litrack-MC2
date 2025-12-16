//
//  LitrackApp.swift
//  Litrack-MC2
//
//  SwiftUI Migration - Main App Entry Point
//  Copyright © 2024 Litrack Team. All rights reserved.
//

import SwiftUI

@main
struct LitrackApp: App {
    @StateObject private var dataController = DataController.shared
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(appState)
                .preferredColorScheme(appState.isDarkMode ? .dark : .light)
        }
    }
}

// MARK: - App State
@MainActor
class AppState: ObservableObject {
    @Published var isDarkMode: Bool = false
    @Published var selectedTab: Tab = .home
    @Published var showCamera: Bool = false
    
    enum Tab {
        case home
        case history
        case analytics
        case settings
    }
}
