//
//  ContentView.swift
//  Litrack-MC2
//
//  Main SwiftUI View with Tab Navigation
//  Copyright © 2024 Litrack Team. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.6), value: showSplash)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showSplash = false
            }
        }
    }
}

// MARK: - Main Tab View
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

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var appState: AppState
    @Namespace private var animation
    
    let tabs = [
        (icon: "house.fill", title: "Home"),
        (icon: "clock.fill", title: "History"),
        (icon: "chart.bar.fill", title: "Analytics"),
        (icon: "gearshape.fill", title: "Settings")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                if index == 2 {
                    // Camera button in the middle
                    Button {
                        appState.showCamera = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "11998e"), Color(hex: "38ef7d")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 60, height: 60)
                                .shadow(color: Color(hex: "11998e").opacity(0.5), radius: 10, x: 0, y: 5)
                            
                            Image(systemName: "camera.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .offset(y: -20)
                    .frame(maxWidth: .infinity)
                }
                
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tabs[index].icon)
                            .font(.system(size: 20, weight: selectedTab == index ? .bold : .regular))
                            .foregroundColor(selectedTab == index ? Color(hex: "38ef7d") : .white.opacity(0.6))
                        
                        Text(tabs[index].title)
                            .font(.system(size: 10, weight: selectedTab == index ? .semibold : .regular))
                            .foregroundColor(selectedTab == index ? Color(hex: "38ef7d") : .white.opacity(0.6))
                        
                        if selectedTab == index {
                            Circle()
                                .fill(Color(hex: "38ef7d"))
                                .frame(width: 4, height: 4)
                                .matchedGeometryEffect(id: "tab", in: animation)
                        } else {
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 4, height: 4)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Splash View
struct SplashView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
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
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "11998e"), Color(hex: "38ef7d")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .blur(radius: 30)
                    
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color(hex: "38ef7d")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .scaleEffect(scale)
                
                VStack(spacing: 8) {
                    Text("Litrack")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Smart Waste Tracking with AI")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                scale = 1.0
            }
            withAnimation(.easeIn(duration: 0.6).delay(0.2)) {
                opacity = 1.0
            }
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environment(\.managedObjectContext, DataController.shared.container.viewContext)
}
