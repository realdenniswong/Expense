//
//  SpendingChartView.swift
//  Expense
//
//  Created by Dennis Wong on 11/6/2025.
//

import SwiftUI
import Charts

struct SpendingChartView: View {
    let categorySpendings: [CategorySpending]
    
    init(categorySpendingTotals: [CategorySpending]) {
        self.categorySpendings = categorySpendingTotals
    }

    var body: some View {
        Chart(categorySpendings, id: \.category.rawValue) { element in
            SectorMark(
                angle: .value("Amount", element.amount)
            )
            .foregroundStyle(by: .value("Category", element.category.rawValue))
            .opacity(0.8) // Slightly transparent like Apple charts
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
            // Clean background like Apple's charts
            Color.clear
        }
        .frame(height: 320)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12) // Apple uses 12pt corners
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(
                    color: Color.black.opacity(0.04),
                    radius: 4,
                    x: 0,
                    y: 1
                ) // Subtler shadow like Apple
        )
    }
}
