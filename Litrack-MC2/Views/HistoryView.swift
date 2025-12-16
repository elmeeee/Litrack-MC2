//
//  HistoryView.swift
//  Litrack-MC2
//
//  History View with Filtering
//  Copyright © 2024 Litrack Team. All rights reserved.
//

import SwiftUI
import CoreData

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WasteEntry.timestamp, ascending: false)],
        animation: .default)
    private var wasteEntries: FetchedResults<WasteEntry>
    
    @State private var selectedFilter: FilterType = .all
    @State private var searchText = ""
    
    enum FilterType: String, CaseIterable {
        case all = "All"
        case plastic = "Plastic"
        case can = "Can"
        case glass = "Glass"
    }
    
    var filteredEntries: [WasteEntry] {
        var entries = Array(wasteEntries)
        
        if selectedFilter != .all {
            entries = entries.filter { $0.type == selectedFilter.rawValue }
        }
        
        if !searchText.isEmpty {
            entries = entries.filter { entry in
                entry.type?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
        
        return entries
    }
    
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
                        // Subtitle
                        Text("\(filteredEntries.count) items tracked")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 10)
                        
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white.opacity(0.6))
                            
                            TextField("Search...", text: $searchText)
                                .foregroundColor(.white)
                                .tint(Color(hex: "38ef7d"))
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                        
                        // Filter Chips
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(FilterType.allCases, id: \.self) { filter in
                                    FilterChip(
                                        title: filter.rawValue,
                                        isSelected: selectedFilter == filter
                                    ) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedFilter = filter
                                        }
                                    }
                                }
                            }
                        }
                        
                        // History List
                        if filteredEntries.isEmpty {
                            EmptyHistoryView()
                                .padding(.top, 60)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredEntries, id: \.id) { entry in
                                    HistoryCard(entry: entry)
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .leading).combined(with: .opacity)
                                        ))
                                }
                            }
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
                .navigationTitle("History")
                .toolbarColorScheme(.dark, for: .navigationBar)
            }
        }
    }
    
    // MARK: - Filter Chip
    struct FilterChip: View {
        let title: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                isSelected ?
                                LinearGradient(
                                    colors: [Color(hex: "11998e"), Color(hex: "38ef7d")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ) :
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.1), Color.white.opacity(0.1)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        isSelected ? Color.clear : Color.white.opacity(0.2),
                                        lineWidth: 1
                                    )
                            )
                    )
            }
        }
    }
    
    // MARK: - History Card
    struct HistoryCard: View {
        let entry: WasteEntry
        @State private var showDetails = false
        
        var iconName: String {
            switch entry.type {
            case "Plastic": return "drop.fill"
            case "Can": return "cylinder.fill"
            case "Glass": return "wineglass.fill"
            default: return "cube.fill"
            }
        }
        
        var iconColor: [Color] {
            switch entry.type {
            case "Plastic": return [Color(hex: "667eea"), Color(hex: "764ba2")]
            case "Can": return [Color(hex: "f093fb"), Color(hex: "f5576c")]
            case "Glass": return [Color(hex: "4facfe"), Color(hex: "00f2fe")]
            default: return [Color(hex: "11998e"), Color(hex: "38ef7d")]
            }
        }
        
        var body: some View {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showDetails.toggle()
                }
            } label: {
                VStack(spacing: 0) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: iconColor,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: iconName)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(entry.type ?? "Unknown")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(entry.timestamp?.formatted(date: .abbreviated, time: .shortened) ?? "")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 6) {
                            Text("\(Int(entry.confidence * 100))%")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(hex: "38ef7d"))
                            
                            Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    .padding(16)
                    
                    if showDetails {
                        VStack(alignment: .leading, spacing: 12) {
                            Divider()
                                .background(Color.white.opacity(0.2))
                            
                            HStack {
                                DetailRow(icon: "calendar", title: "Date", value: entry.timestamp?.formatted(date: .long, time: .omitted) ?? "")
                                Spacer()
                            }
                            
                            HStack {
                                DetailRow(icon: "clock", title: "Time", value: entry.timestamp?.formatted(date: .omitted, time: .shortened) ?? "")
                                Spacer()
                            }
                            
                            HStack {
                                DetailRow(icon: "percent", title: "Confidence", value: "\(Int(entry.confidence * 100))%")
                                Spacer()
                            }
                        }
                        .padding(16)
                        .padding(.top, -8)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: iconColor.map { $0.opacity(0.3) },
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
            }
        }
    }
    
    // MARK: - Detail Row
    struct DetailRow: View {
        let icon: String
        let title: String
        let value: String
        
        var body: some View {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 20)
                
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                Text(value)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }
    
    // MARK: - Empty History View
    struct EmptyHistoryView: View {
        var body: some View {
            VStack(spacing: 16) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(.white.opacity(0.5))
                
                Text("No History Yet")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Start scanning waste items to build your tracking history")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 60)
        }
    }
    
}
