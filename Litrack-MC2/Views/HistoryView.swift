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
        case paper = "Paper"
        case cardboard = "Cardboard"
        case biological = "Biological"
        case metal = "Metal"
        case plastic = "Plastic"
        case greenGlass = "Green-glass"
        case brownGlass = "Brown-glass"
        case whiteGlass = "White-glass"
        case clothes = "Clothes"
        case shoes = "Shoes"
        case batteries = "Batteries"
        case trash = "Trash"
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
                
                VStack(spacing: 0) {
                    // Header Section
                    VStack(spacing: 16) {
                        Text("\(filteredEntries.count) items tracked")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white.opacity(0.6))
                            
                            TextField("Search...", text: $searchText)
                                .foregroundColor(.white)
                                .tint(.green)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
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
                                        withAnimation(.spring()) {
                                            selectedFilter = filter
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(.ultraThinMaterial)
                    
                    // History List
                    if filteredEntries.isEmpty {
                        EmptyHistoryView()
                            .padding(.top, 60)
                        Spacer()
                    } else {
                        List {
                            ForEach(filteredEntries, id: \.id) { entry in
                                HistoryCard(entry: entry)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            deleteEntry(entry)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
                .navigationTitle("History")
                .toolbarColorScheme(.dark, for: .navigationBar)
            }
        }
    }
    
    private func deleteEntry(_ entry: WasteEntry) {
        withAnimation {
            viewContext.delete(entry)
            try? viewContext.save()
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
                            .fill(isSelected ? Color.green : Color.white.opacity(0.1))
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
            case "Paper": return "newspaper.fill"
            case "Cardboard": return "box.truck.fill"
            case "Biological": return "leaf.fill"
            case "Metal": return "gear"
            case "Plastic": return "drop.fill"
            case "Green-glass": return "wineglass.fill"
            case "Brown-glass": return "wineglass.fill"
            case "White-glass": return "wineglass.fill"
            case "Clothes": return "tshirt.fill"
            case "Shoes": return "shoe.fill"
            case "Batteries": return "battery.100.bolt"
            case "Trash": return "trash.fill"
            default: return "cube.fill"
            }
        }
        
        var iconColor: Color {
            switch entry.type {
            case "Paper": return .white
            case "Cardboard": return Color(hex: "D2B48C")
            case "Biological": return .green
            case "Metal": return .gray
            case "Plastic": return .blue
            case "Green-glass": return Color(hex: "56ab2f")
            case "Brown-glass": return Color(hex: "8D6E63")
            case "White-glass": return Color(hex: "E0F7FA")
            case "Clothes": return .pink
            case "Shoes": return .primary
            case "Batteries": return .orange
            case "Trash": return .secondary
            default: return .green
            }
        }
        
        func loadImage(named: String) -> UIImage? {
            guard let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
            let url = docDir.appendingPathComponent(named)
            return UIImage(contentsOfFile: url.path)
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
                            if let imageName = entry.imageName,
                               let image = loadImage(named: imageName) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(iconColor, lineWidth: 2))
                            } else {
                                Circle()
                                    .fill(iconColor)
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: iconName)
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(entry.type == "Paper" || entry.type == "White-glass" ? .black : .white)
                            }
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
                                .foregroundColor(.green)
                            
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
                                .stroke(iconColor.opacity(0.5), lineWidth: 1)
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

