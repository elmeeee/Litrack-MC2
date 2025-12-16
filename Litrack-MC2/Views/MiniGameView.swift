//
//  MiniGameView.swift
//  Litrack-MC2
//
//  Created by Antigravity on 2024-12-16.
//

import SwiftUI

struct MiniGameView: View {
    @State private var score = 0
    @State private var timeRemaining = 30
    @State private var gameActive = false
    @State private var currentItem: WasteItem?
    @State private var options: [String] = []
    @State private var streak = 0
    @State private var showGameOver = false
    @State private var feedbackColor: Color = .clear
    @State private var feedbackOpacity = 0.0
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let categories = [
        "Paper", "Cardboard", "Biological", "Metal", "Plastic",
        "Green-glass", "Brown-glass", "White-glass", "Clothes",
        "Shoes", "Batteries", "Trash"
    ]
    
    // Manual mapping of distinct icons for the game
    func icon(for category: String) -> String {
        switch category {
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
        default: return "questionmark.circle.fill"
        }
    }
    
    func color(for category: String) -> [Color] {
        switch category {
        case "Paper": return [Color.white, Color.gray]
        case "Cardboard": return [Color(hex: "D2B48C"), Color(hex: "A0522D")]
        case "Biological": return [Color(hex: "11998e"), Color(hex: "38ef7d")]
        case "Metal": return [Color(hex: "bdc3c7"), Color(hex: "2c3e50")]
        case "Plastic": return [Color(hex: "667eea"), Color(hex: "764ba2")]
        case "Green-glass": return [Color(hex: "56ab2f"), Color(hex: "a8e063")]
        case "Brown-glass": return [Color(hex: "8D6E63"), Color(hex: "5D4037")]
        case "White-glass": return [Color(hex: "E0F7FA"), Color(hex: "B2EBF2")]
        case "Clothes": return [Color(hex: "ff9a9e"), Color(hex: "fecfef")]
        case "Shoes": return [Color(hex: "29323c"), Color(hex: "485563")]
        case "Batteries": return [Color(hex: "ff6a00"), Color(hex: "ee0979")]
        case "Trash": return [Color(hex: "304352"), Color(hex: "d7d2cc")]
        default: return [Color.gray, Color.black]
        }
    }
    
    struct WasteItem {
        let category: String
        let icon: String
        let colors: [Color]
    }
    
    var body: some View {
        ZStack {
            // Animated Background
            LinearGradient(
                colors: [Color(hex: "0F2027"), Color(hex: "203A43"), Color(hex: "2C5364")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Feedback Overlay
            Rectangle()
                .fill(feedbackColor)
                .opacity(feedbackOpacity)
                .ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Waste Sort Blitz")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        Text("Score: \(score)")
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text("\(streak)")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        
                        Text("\(timeRemaining)s")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(timeRemaining <= 5 ? .red : .white)
                    }
                }
                .padding()
                
                Spacer()
                
                if gameActive {
                    // Game Area
                    VStack(spacing: 40) {
                        
                        if let item = currentItem {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: item.colors,
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 180, height: 180)
                                    .shadow(color: item.colors[0].opacity(0.5), radius: 30, x: 0, y: 10)
                                
                                Image(systemName: item.icon)
                                    .font(.system(size: 80))
                                    .foregroundColor(.white)
                                    .shadow(radius: 5)
                            }
                            .transition(.scale.combined(with: .opacity))
                            .id(item.category + "\(score)") // Force redraw for animation
                        }
                        
                        // Options Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(options, id: \.self) { option in
                                Button {
                                    handleAnswer(option)
                                } label: {
                                    Text(option)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 70)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(.ultraThinMaterial)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                                )
                                        )
                                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    // Start Screen
                    VStack(spacing: 20) {
                        Text(showGameOver ? "Game Over" : "Ready?")
                            .font(.system(size: 40, weight: .black))
                            .foregroundColor(.white)
                        
                        if showGameOver {
                            Text("Final Score: \(score)")
                                .font(.title)
                                .foregroundColor(.white)
                            
                            Button {
                                startGame()
                            } label: {
                                Text("Play Again")
                                    .font(.title3.bold())
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 40)
                                    .padding(.vertical, 16)
                                    .background(Color.white)
                                    .cornerRadius(20)
                            }
                        } else {
                            Button {
                                startGame()
                            } label: {
                                Text("Start Game")
                                    .font(.title3.bold())
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 40)
                                    .padding(.vertical, 16)
                                    .background(Color.white)
                                    .cornerRadius(20)
                            }
                        }
                    }
                }
                
                Spacer()
            }
        }
        .onReceive(timer) { _ in
            if gameActive {
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    gameOver()
                }
            }
        }
    }
    
    private func startGame() {
        score = 0
        streak = 0
        timeRemaining = 30
        gameActive = true
        showGameOver = false
        nextRound()
    }
    
    private func gameOver() {
        gameActive = false
        showGameOver = true
    }
    
    private func nextRound() {
        guard let correctCategory = categories.randomElement() else { return }
        
        let correctItem = WasteItem(
            category: correctCategory,
            icon: icon(for: correctCategory),
            colors: color(for: correctCategory)
        )
        
        currentItem = correctItem
        
        // Generate options (1 correct + 3 wrong)
        var newOptions = [correctCategory]
        while newOptions.count < 4 {
            if let randomOption = categories.randomElement(), !newOptions.contains(randomOption) {
                newOptions.append(randomOption)
            }
        }
        options = newOptions.shuffled()
    }
    
    private func handleAnswer(_ answer: String) {
        let isCorrect = answer == currentItem?.category
        
        if isCorrect {
            score += 10 + (streak * 2)
            streak += 1
            triggerFeedback(color: .green)
            nextRound()
        } else {
            streak = 0
            if timeRemaining > 2 {
                timeRemaining -= 2 // Penalty
            }
            triggerFeedback(color: .red)
            // Vibrate
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
    
    private func triggerFeedback(color: Color) {
        feedbackColor = color
        withAnimation(.easeIn(duration: 0.1)) {
            feedbackOpacity = 0.3
        }
        withAnimation(.easeOut(duration: 0.2).delay(0.1)) {
            feedbackOpacity = 0.0
        }
    }
}

#Preview {
    MiniGameView()
}
