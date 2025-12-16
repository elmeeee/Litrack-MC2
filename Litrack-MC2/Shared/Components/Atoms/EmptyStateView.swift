//
//  EmptyStateView.swift
//  Litrack-MC2
//
//  Reusable Empty State Component (Atom)
//  Copyright © 2024 Litrack Team. All rights reserved.
//

import SwiftUI

struct EmptyStateView: View {
    var icon: String = "tray"
    var title: String = "No activity yet"
    var message: String = "Start tracking waste to see your impact"
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40, weight: .light))
                .foregroundColor(.white.opacity(0.5))
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            Text(message)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

#Preview {
    EmptyStateView()
        .background(Color.black)
}
