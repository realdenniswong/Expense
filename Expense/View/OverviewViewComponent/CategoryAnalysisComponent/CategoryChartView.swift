//
//  CategoryChartView.swift
//  Expense
//
//  Created by Dennis Wong on 12/6/2025.
//
import SwiftUI
import Charts

struct CategoryChartView: View {
    let categorySpendingTotals: [CategorySpending]
    let period: TimePeriod
    
    var body: some View {
        if categorySpendingTotals.isEmpty {
            EmptyChartView(period: period)
                .padding(.horizontal, 20)
        } else {
            Chart(categorySpendingTotals, id: \.category.rawValue) { element in
                SectorMark(
                    angle: .value("Amount", element.amountInCent)
                )
                .foregroundStyle(by: .value("Category", element.category.rawValue))
                .opacity(0.8)
            }
            .chartForegroundStyleScale([
                "Food & Drink": .orange,
                "Transportation": .blue,
                "Shopping": .purple,
                "Entertainment": .yellow,
                "Bills & Utilities": .red,
                "Healthcare": .green,
                "Other": .brown
            ])
            .chartLegend(position: .bottom, alignment: .center, spacing: 16)
            .chartBackground { chartProxy in
                Color.clear
            }
            .frame(height: 350)
            .padding(.horizontal, 10)  // ← Move padding here
            .animation(.easeInOut(duration: 0.3), value: period)
        }
    }
}
