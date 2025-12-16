//
//  LitrackApp.swift
//  Litrack-MC2
//
//  Main App Entry Point
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
