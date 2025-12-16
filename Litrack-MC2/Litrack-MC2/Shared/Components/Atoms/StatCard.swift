//
//  StatCard.swift
//  Litrack-MC2
//
//  Reusable Stat Card Component (Atom)
//  Copyright © 2024 Litrack Team. All rights reserved.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: [Color]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
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
                        .stroke(
                            LinearGradient(
                                colors: gradient.map { $0.opacity(0.5) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: gradient[0].opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    StatCard(
        title: "Total Items",
        value: "42",
        icon: "cube.fill",
        gradient: [Color(hex: "667eea"), Color(hex: "764ba2")]
    )
    .padding()
    .background(Color.black)
}
