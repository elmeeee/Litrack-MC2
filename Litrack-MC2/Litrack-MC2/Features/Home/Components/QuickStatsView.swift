//
//  QuickStatsView.swift
//  Litrack-MC2
//
//  Home Feature - Quick Stats Component
//  Copyright © 2024 Litrack Team. All rights reserved.
//

import SwiftUI

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
                    gradient: [Color(hex: "667eea"), Color(hex: "764ba2")]
                )
                
                StatCard(
                    title: "This Week",
                    value: "\(thisWeekItems)",
                    icon: "calendar",
                    gradient: [Color(hex: "f093fb"), Color(hex: "f5576c")]
                )
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Most Common",
                    value: mostCommonType,
                    icon: "star.fill",
                    gradient: [Color(hex: "4facfe"), Color(hex: "00f2fe")]
                )
                
                StatCard(
                    title: "Streak",
                    value: "7 Days",
                    icon: "flame.fill",
                    gradient: [Color(hex: "fa709a"), Color(hex: "fee140")]
                )
            }
        }
    }
}

#Preview {
    QuickStatsView(entries: [])
        .padding()
        .background(Color.black)
}
