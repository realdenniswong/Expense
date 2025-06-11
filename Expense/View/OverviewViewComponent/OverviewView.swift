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
        Dictionary(grouping: expenses, by: { $0.category })
            .mapValues { expenses in
                expenses.reduce(0) { $0 + $1.amount }
            }
            .map { categoryTotal in
                CategorySpending(
                    category: categoryTotal.key,
                    amount: categoryTotal.value,
                    percentage: (categoryTotal.value / totalAmount) * 100
                )
            }
            .sorted { $0.amount > $1.amount }
    }
    
    private var totalAmount: Double {
        expenses.reduce(0) { $0 + $1.amount }
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
