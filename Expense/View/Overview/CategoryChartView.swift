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
                .foregroundStyle(element.category.color)
                .opacity(0.8)
            }
            .chartBackground { chartProxy in
                Color.clear
            }
            .frame(height: 350)
            .padding(.horizontal, 10)
            .animation(.easeInOut(duration: 0.3), value: period)
        }
    }
}
