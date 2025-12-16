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
                // Add Camera Button before the 3rd tab (index 2)
                if index == 2 {
                    Button {
                        appState.showCamera = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 60, height: 60)
                                .shadow(color: Color.white.opacity(0.2), radius: 10, x: 0, y: 5)
                            
                            Image(systemName: "camera.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                    .offset(y: -20)
                    .frame(maxWidth: .infinity)
                }
                
                // Tab Button
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tabs[index].icon)
                            .font(.system(size: 20, weight: selectedTab == index ? .bold : .regular))
                            .foregroundColor(selectedTab == index ? .white : .white.opacity(0.5))
                        
                        Text(tabs[index].title)
                            .font(.system(size: 10, weight: selectedTab == index ? .semibold : .regular))
                            .foregroundColor(selectedTab == index ? .white : .white.opacity(0.5))
                        
                        if selectedTab == index {
                            Circle()
                                .fill(Color.white)
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
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(.thickMaterial)
                
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(hex: "0F2027").opacity(0.8))
            }
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        )
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        .ignoresSafeArea(.keyboard)
    }
}

