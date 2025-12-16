//
//  AnalyticsView.swift
//  Litrack-MC2
//
//  Analytics View with Charts
//  Copyright © 2024 Litrack Team. All rights reserved.
//

import SwiftUI
import Charts
import CoreData

struct AnalyticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WasteEntry.timestamp, ascending: false)],
        animation: .default)
    private var wasteEntries: FetchedResults<WasteEntry>
    
    @State private var selectedPeriod: Period = .week
    @State private var animateCharts = false
    
    enum Period: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Analytics")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Track your environmental impact")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 60)
                
                // Period Selector
                PeriodSelector(selectedPeriod: $selectedPeriod)
                
                // Type Distribution Chart
                TypeDistributionChart(entries: filteredEntries)
                    .opacity(animateCharts ? 1 : 0)
                    .offset(y: animateCharts ? 0 : 20)
                
                // Timeline Chart
                TimelineChart(entries: filteredEntries, period: selectedPeriod)
                    .opacity(animateCharts ? 1 : 0)
                    .offset(y: animateCharts ? 0 : 20)
                
                // Statistics Grid
                StatisticsGrid(entries: filteredEntries)
                    .opacity(animateCharts ? 1 : 0)
                    .offset(y: animateCharts ? 0 : 20)
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                animateCharts = true
            }
        }
    }
    
    var filteredEntries: [WasteEntry] {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date
        switch selectedPeriod {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        }
        
        return wasteEntries.filter { entry in
            guard let timestamp = entry.timestamp else { return false }
            return timestamp >= startDate
        }
    }
}

// MARK: - Period Selector
struct PeriodSelector: View {
    @Binding var selectedPeriod: AnalyticsView.Period
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AnalyticsView.Period.allCases, id: \.self) { period in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedPeriod = period
                    }
                } label: {
                    Text(period.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(selectedPeriod == period ? .white : .white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            ZStack {
                                if selectedPeriod == period {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(hex: "11998e"), Color(hex: "38ef7d")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .matchedGeometryEffect(id: "period", in: animation)
                                }
                            }
                        )
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Type Distribution Chart
struct TypeDistributionChart: View {
    let entries: [WasteEntry]
    
    var typeData: [(type: String, count: Int, color: [Color])] {
        let types = ["Plastic", "Can", "Glass"]
        let colors: [[Color]] = [
            [Color(hex: "667eea"), Color(hex: "764ba2")],
            [Color(hex: "f093fb"), Color(hex: "f5576c")],
            [Color(hex: "4facfe"), Color(hex: "00f2fe")]
        ]
        
        return types.enumerated().map { index, type in
            let count = entries.filter { $0.type == type }.count
            return (type, count, colors[index])
        }
    }
    
    var totalCount: Int {
        typeData.reduce(0) { $0 + $1.count }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Type Distribution")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            if totalCount == 0 {
                EmptyChartView(message: "No data available")
            } else {
                // Pie Chart
                Chart(typeData, id: \.type) { data in
                    SectorMark(
                        angle: .value("Count", data.count),
                        innerRadius: .ratio(0.6),
                        angularInset: 2
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: data.color,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
                .frame(height: 200)
                
                // Legend
                VStack(spacing: 12) {
                    ForEach(typeData, id: \.type) { data in
                        HStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: data.color,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 12, height: 12)
                            
                            Text(data.type)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(data.count)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("(\(totalCount > 0 ? Int(Double(data.count) / Double(totalCount) * 100) : 0)%)")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Timeline Chart
struct TimelineChart: View {
    let entries: [WasteEntry]
    let period: AnalyticsView.Period
    
    var timelineData: [(date: Date, count: Int)] {
        let calendar = Calendar.current
        let now = Date()
        
        let days: Int
        switch period {
        case .week: days = 7
        case .month: days = 30
        case .year: days = 365
        }
        
        return (0..<days).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) ?? now
            let count = entries.filter { entry in
                guard let timestamp = entry.timestamp else { return false }
                return calendar.isDate(timestamp, inSameDayAs: date)
            }.count
            return (date, count)
        }.reversed()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity Timeline")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            if timelineData.allSatisfy({ $0.count == 0 }) {
                EmptyChartView(message: "No activity in this period")
            } else {
                Chart(timelineData, id: \.date) { data in
                    AreaMark(
                        x: .value("Date", data.date),
                        y: .value("Count", data.count)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(hex: "11998e").opacity(0.6),
                                Color(hex: "38ef7d").opacity(0.2)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    LineMark(
                        x: .value("Date", data.date),
                        y: .value("Count", data.count)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "11998e"), Color(hex: "38ef7d")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 5)) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.white.opacity(0.2))
                        AxisValueLabel()
                            .foregroundStyle(Color.white.opacity(0.6))
                            .font(.system(size: 10))
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.white.opacity(0.2))
                        AxisValueLabel()
                            .foregroundStyle(Color.white.opacity(0.6))
                            .font(.system(size: 10))
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Statistics Grid
struct StatisticsGrid: View {
    let entries: [WasteEntry]
    
    var averageConfidence: Double {
        guard !entries.isEmpty else { return 0 }
        let sum = entries.reduce(0.0) { $0 + $1.confidence }
        return sum / Double(entries.count)
    }
    
    var mostActiveDay: String {
        let calendar = Calendar.current
        let days = entries.compactMap { $0.timestamp }.map { calendar.component(.weekday, from: $0) }
        let counted = days.reduce(into: [:]) { counts, day in
            counts[day, default: 0] += 1
        }
        guard let mostCommon = counted.max(by: { $0.value < $1.value })?.key else {
            return "N/A"
        }
        return calendar.weekdaySymbols[mostCommon - 1]
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                MiniStatCard(
                    title: "Avg Confidence",
                    value: "\(Int(averageConfidence * 100))%",
                    icon: "chart.line.uptrend.xyaxis"
                )
                
                MiniStatCard(
                    title: "Total Scans",
                    value: "\(entries.count)",
                    icon: "camera.fill"
                )
            }
            
            HStack(spacing: 16) {
                MiniStatCard(
                    title: "Most Active",
                    value: mostActiveDay,
                    icon: "calendar.badge.clock"
                )
                
                MiniStatCard(
                    title: "This Period",
                    value: "\(entries.count)",
                    icon: "clock.arrow.circlepath"
                )
            }
        }
    }
}

// MARK: - Mini Stat Card
struct MiniStatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "11998e"), Color(hex: "38ef7d")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
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

// MARK: - Empty Chart View
struct EmptyChartView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(.white.opacity(0.4))
            
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
    }
}

#Preview {
    AnalyticsView()
        .environment(\.managedObjectContext, DataController.shared.container.viewContext)
        .background(
            LinearGradient(
                colors: [Color(hex: "0F2027"), Color(hex: "203A43"), Color(hex: "2C5364")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
}
