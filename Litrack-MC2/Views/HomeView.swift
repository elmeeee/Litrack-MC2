//
//  HomeView.swift
//  Litrack-MC2
//
//  Home Dashboard with Statistics
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
        NavigationStack {
            ZStack {
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
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Welcome Text
                        Text("Welcome Back!")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 10)
                        
                        // Quick Stats Cards
                        QuickStatsView(entries: Array(wasteEntries))
                            .scaleEffect(animateStats ? 1 : 0.8)
                            .opacity(animateStats ? 1 : 0)
                        
                        // Weekly Progress
                        WeeklyProgressView(entries: Array(wasteEntries))
                        
                        // Recent Activity
                        RecentActivityView(entries: Array(wasteEntries.prefix(5)))
                        
                        // Environmental Impact
                        EnvironmentalImpactView(entries: Array(wasteEntries))
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Circle().fill(.ultraThinMaterial))
                    }
                }
            }
            .navigationTitle("Track Your Impact")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                animateStats = true
            }
        }
    }
}


// MARK: - Quick Stats View
struct QuickStatsView: View {
    let entries: [WasteEntry]
    
    var totalItems: Int {
        entries.count
    }
    
    var thisWeekItems: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return entries.filter { $0.timestamp ?? Date() >= weekAgo }.count
    }
    
    var mostCommonType: String {
        let types = entries.compactMap { $0.type }
        let counted = types.reduce(into: [:]) { counts, type in
            counts[type, default: 0] += 1
        }
        return counted.max(by: { $0.value < $1.value })?.key ?? "None"
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                StatCard(
                    title: "Total Items",
                    value: "\(totalItems)",
                    icon: "cube.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "This Week",
                    value: "\(thisWeekItems)",
                    icon: "calendar",
                    color: .orange
                )
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Most Common",
                    value: mostCommonType,
                    icon: "star.fill",
                    color: .teal
                )
                
                StatCard(
                    title: "Streak",
                    value: "7 Days",
                    icon: "flame.fill",
                    color: .yellow
                )
            }
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(color.opacity(0.5), lineWidth: 1)
                )
        )
        .shadow(color: color.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Weekly Progress View
struct WeeklyProgressView: View {
    let entries: [WasteEntry]
    
    var weeklyData: [(day: String, count: Int)] {
        let calendar = Calendar.current
        let today = Date()
        
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) ?? today
            let dayName = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
            
            let count = entries.filter { entry in
                guard let timestamp = entry.timestamp else { return false }
                return calendar.isDate(timestamp, inSameDayAs: date)
            }.count
            
            return (dayName, count)
        }.reversed()
    }
    
    var maxCount: Int {
        weeklyData.map { $0.count }.max() ?? 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly Activity")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(weeklyData, id: \.day) { data in
                    VStack(spacing: 8) {
                        ZStack(alignment: .bottom) {
                            // Background bar
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 100)
                            
                            // Filled bar
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.green)
                                .frame(height: CGFloat(data.count) / CGFloat(maxCount) * 100)
                        }
                        
                        Text(data.day)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 130)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Recent Activity View
struct RecentActivityView: View {
    let entries: [WasteEntry]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            if entries.isEmpty {
                EmptyStateView()
            } else {
                VStack(spacing: 12) {
                    ForEach(entries, id: \.id) { entry in
                        ActivityRow(entry: entry)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Activity Row
struct ActivityRow: View {
    let entry: WasteEntry
    
    var iconName: String {
        switch entry.type {
        case "Plastic": return "drop.fill"
        case "Can": return "cylinder.fill"
        case "Glass": return "wineglass.fill"
        default: return "cube.fill"
        }
    }
    
    var iconColor: Color {
        switch entry.type {
        case "Plastic": return .blue
        case "Can": return .red
        case "Glass": return .orange
        default: return .green
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor)
                    .frame(width: 44, height: 44)
                
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.type ?? "Unknown")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(entry.timestamp?.formatted(date: .abbreviated, time: .shortened) ?? "")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(entry.confidence * 100))%")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.green)
                
                Text("Confidence")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// MARK: - Environmental Impact View
struct EnvironmentalImpactView: View {
    let entries: [WasteEntry]
    
    var co2Saved: Double {
        Double(entries.count) * 0.5 // Approximate kg CO2 saved per item
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.green)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Environmental Impact")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Your contribution to a greener planet")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                ImpactCard(
                    value: String(format: "%.1f kg", co2Saved),
                    title: "CO₂ Saved",
                    icon: "cloud.fill"
                )
                
                ImpactCard(
                    value: "\(entries.count)",
                    title: "Items Recycled",
                    icon: "arrow.3.trianglepath"
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Impact Card
struct ImpactCard: View {
    let value: String
    let title: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.green)
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(.white.opacity(0.5))
            
            Text("No activity yet")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            Text("Start tracking waste to see your impact")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
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
