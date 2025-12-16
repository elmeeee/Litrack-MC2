//
//  AppState.swift
//  Litrack-MC2
//
//  Global App State Management
//  Copyright © 2024 Litrack Team. All rights reserved.
//

import SwiftUI

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
