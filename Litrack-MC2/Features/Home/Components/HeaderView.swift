//
//  HeaderView.swift
//  Litrack-MC2
//
//  Home Feature - Header Component
//  Copyright © 2024 Litrack Team. All rights reserved.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome Back!")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            Text("Track Your Impact")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    HeaderView()
        .padding()
        .background(Color.black)
}
