//
//  CustomTabBar.swift
//  Litrack-MC2
//
//  Custom Tab Bar Component
//  Copyright © 2024 Litrack Team. All rights reserved.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var appState: AppState
    @Namespace private var animation
    
    let tabs = [
        (tag: 0, icon: "house.fill", title: "Home"),
        (tag: 1, icon: "clock.fill", title: "History"),
        (tag: 2, icon: "gamecontroller.fill", title: "Game"),
        (tag: 3, icon: "gearshape.fill", title: "Settings")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Gradient Divider
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.1), .white.opacity(0.3), .white.opacity(0.1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
            
            HStack(spacing: 0) {
                // First 2 Tabs
                ForEach(tabs.prefix(2), id: \.tag) { tab in
                    TabBarButton(
                        icon: tab.icon,
                        title: tab.title,
                        tag: tab.tag,
                        selectedTab: $selectedTab,
                        animation: animation
                    )
                }
                
                // Camera Button (Center)
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
                            .frame(width: 64, height: 64)
                            .shadow(color: Color(hex: "38ef7d").opacity(0.4), radius: 10, x: 0, y: 5)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        
                        Image(systemName: "camera.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .offset(y: -24)
                .frame(width: 80)
                
                // Last 2 Tabs
                ForEach(tabs.suffix(2), id: \.tag) { tab in
                    TabBarButton(
                        icon: tab.icon,
                        title: tab.title,
                        tag: tab.tag,
                        selectedTab: $selectedTab,
                        animation: animation
                    )
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 20) // Safe Area padding handled manually or by system if not ignored
            .padding(.top, 12)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Rectangle()
                            .fill(Color(hex: "0F2027").opacity(0.6))
                    )
                    .ignoresSafeArea()
            )
        }
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let tag: Int
    @Binding var selectedTab: Int
    var animation: Namespace.ID
    
    var isSelected: Bool {
        selectedTab == tag
    }
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tag
            }
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(Color(hex: "38ef7d").opacity(0.2))
                            .frame(width: 40, height: 40)
                            .matchedGeometryEffect(id: "tab_bg", in: animation)
                    }
                    
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: isSelected ? .bold : .regular))
                        .foregroundColor(isSelected ? Color(hex: "38ef7d") : .white.opacity(0.6))
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                }
                
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

