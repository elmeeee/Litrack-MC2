//
//  SettingsView.swift
//  Litrack-MC2
//
//  Settings View
//  Copyright © 2024 Litrack Team. All rights reserved.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showClearDataAlert = false
    @State private var showAbout = false
    
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
                        Text("Customize your experience")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 10)
                
                // Appearance Section
                SettingsSection(title: "Appearance") {
                    SettingsToggle(
                        icon: "moon.fill",
                        title: "Dark Mode",
                        subtitle: "Use dark theme",
                        isOn: $appState.isDarkMode,
                        iconColor: .indigo
                    )
                }
                
                // Data Section
                SettingsSection(title: "Data") {
                    SettingsButton(
                        icon: "arrow.clockwise",
                        title: "Sync Data",
                        subtitle: "Sync with iCloud",
                        iconColor: .blue
                    ) {
                        // Sync action
                    }
                    
                    SettingsButton(
                        icon: "square.and.arrow.down",
                        title: "Export Data",
                        subtitle: "Download your data",
                        iconColor: .teal
                    ) {
                        // Export action
                    }
                    
                    SettingsButton(
                        icon: "trash.fill",
                        title: "Clear All Data",
                        subtitle: "Delete all tracked items",
                        iconColor: .red
                    ) {
                        showClearDataAlert = true
                    }
                }
                
                // About Section
                SettingsSection(title: "About") {
                    SettingsButton(
                        icon: "info.circle.fill",
                        title: "About Litrack",
                        subtitle: "Version 2.0.0",
                        iconColor: .orange
                    ) {
                        showAbout = true
                    }
                    
                    SettingsButton(
                        icon: "star.fill",
                        title: "Rate App",
                        subtitle: "Share your feedback",
                        iconColor: .yellow
                    ) {
                        // Rate action
                    }
                    
                    SettingsButton(
                        icon: "envelope.fill",
                        title: "Contact Us",
                        subtitle: "Get in touch",
                        iconColor: .purple
                    ) {
                        // Contact action
                    }
                }
                
                // App Info
                VStack(spacing: 8) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(Color.green)
                    
                    Text("Litrack")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Smart Waste Tracking with AI")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("Made with ❤️ for a greener planet 🌍")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.top, 4)
                }
                .padding(.vertical, 32)
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
        }
    }
            .navigationTitle("Settings")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Clear All Data", isPresented: $showClearDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("This will permanently delete all your tracked waste items. This action cannot be undone.")
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
        }
    }
    
    private func clearAllData() {
        // Delete all WasteEntry objects
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = WasteEntry.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try viewContext.execute(deleteRequest)
            try viewContext.save()
        } catch {
            print("Failed to clear data: \(error.localizedDescription)")
        }
    }
}

// MARK: - Settings Section
struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
                .padding(.leading, 4)
            
            VStack(spacing: 1) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Settings Toggle
struct SettingsToggle: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor)
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(Color(hex: "38ef7d"))
        }
        .padding(16)
    }
}

// MARK: - Settings Button
struct SettingsButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(iconColor)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(16)
        }
    }
}

// MARK: - About View
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "0F2027"), Color(hex: "203A43"), Color(hex: "2C5364")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                )
                        }
                    }
                    .padding(.top, 20)
                    
                    // Logo
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 100, height: 100)
                                .blur(radius: 20)
                            
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 50, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Text("Litrack")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Version 2.0.0")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Litrack is an intelligent iOS application that leverages CoreML and CoreData to track and classify plastic, can, and glass waste, helping users make environmentally conscious decisions.")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(0.8))
                            .lineSpacing(4)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    
                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Features")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        FeatureRow(icon: "camera.fill", title: "AI-Powered Classification", description: "Automatically identify waste types")
                        FeatureRow(icon: "chart.bar.fill", title: "Visual Analytics", description: "Track your waste disposal patterns")
                        FeatureRow(icon: "icloud.fill", title: "Cloud Sync", description: "Seamlessly sync across devices")
                        FeatureRow(icon: "leaf.fill", title: "Environmental Impact", description: "See your contribution to sustainability")
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    
                    // Team
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Team")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Made with ❤️ by the Litrack Team")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("© 2024 Litrack. All rights reserved.")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.green)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
        .environment(\.managedObjectContext, DataController.shared.container.viewContext)
        .background(
            LinearGradient(
                colors: [Color(hex: "0F2027"), Color(hex: "203A43"), Color(hex: "2C5364")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
}
