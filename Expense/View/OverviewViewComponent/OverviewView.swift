//
//  SummaryView.swift
//  Expense
//
//  Created by Dennis Wong on 9/6/2025.
//

import SwiftUI
import Charts

struct OverviewView: View {
    
    let expenses: [Expense]
    
    init(expenses: [Expense]) {
        self.expenses = expenses
    }
    
    private var categorySpendingTotals: [CategorySpending] {
        let categoryTotals = Dictionary(grouping: expenses, by: { $0.category })
            .mapValues { expenses in
                expenses.reduce(0) { $0 + $1.amountInCents }
            }
        
        let totalAmount = categoryTotals.values.reduce(0, +)
        
        return categoryTotals.map { categoryTotal in
            CategorySpending(
                category: categoryTotal.key,
                amountInCent: categoryTotal.value,
                percentage: totalAmount > 0 ?
                    Int(round((Double(categoryTotal.value) / Double(totalAmount)) * 100)) : 0
            )
        }
        .sorted { $0.amountInCent > $1.amountInCent }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                SpendingSummaryView(expenses: expenses)
                if !expenses.isEmpty {
                    SpendingChartView(categorySpendingTotals: categorySpendingTotals)
                    SpendingBreakdownListView(categorySpendingTotals: categorySpendingTotals)
                } else {
                    OverviewEmptyStateView()
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
    }
}
