//
//  HomeView.swift
//  Litrack-MC2
//
//  Home Feature - Main View
//  Copyright © 2024 Litrack Team. All rights reserved.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WasteEntry.timestamp, ascending: false)],
        animation: .default)
    private var wasteEntries: FetchedResults<WasteEntry>
    
    @State private var animateStats = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header
                HeaderView()
                    .padding(.top, 60)
                
                // Quick Stats Cards
                QuickStatsView(entries: Array(wasteEntries))
                    .scaleEffect(animateStats ? 1 : 0.8)
                    .opacity(animateStats ? 1 : 0)
                
                // Weekly Progress
                WeeklyProgressView(entries: Array(wasteEntries))
                
                // Recent Activity
                RecentActivitySection(entries: Array(wasteEntries.prefix(5)))
                
                // Environmental Impact
                EnvironmentalImpactView(entries: Array(wasteEntries))
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                animateStats = true
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(\.managedObjectContext, DataController.shared.container.viewContext)
        .background(
            LinearGradient(
                colors: [Color(hex: "0F2027"), Color(hex: "203A43"), Color(hex: "2C5364")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
}
