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

#Preview {
    CustomTabBar(selectedTab: .constant(0))
        .environmentObject(AppState())
        .padding()
        .background(Color.black)
}
