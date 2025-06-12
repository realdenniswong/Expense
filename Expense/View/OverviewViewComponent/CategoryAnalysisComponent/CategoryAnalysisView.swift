//
//  CategoryAnalysisView.swift
//  Expense
//
//  Created by Dennis Wong on 12/6/2025.
//
import SwiftUI
import Charts

struct CategoryAnalysisView: View {
    let filteredExpenses: FilteredExpenses
    
    private var periodTitle: String {
        switch filteredExpenses.period {
        case .daily: return "Today's Categories"
        case .weekly: return "This Week's Categories"
        case .monthly: return "This Month's Categories"
        }
    }
    
    var body: some View {
        let categorySpendingTotals = filteredExpenses.categorySpendingTotals
        
        VStack(alignment: .leading, spacing: 20) {
            // Title
            Text(periodTitle)
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
                .padding(.top, 20)
            
            // Chart (extracted)
            CategoryChartView(
                categorySpendingTotals: categorySpendingTotals,
                period: filteredExpenses.period
            )
            
            // Breakdown section (only if has data)
            if !categorySpendingTotals.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Breakdown")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                    
                    LazyVStack(spacing: 12) {
                        ForEach(categorySpendingTotals, id: \.category.rawValue) { categorySpending in
                            CategoryBreakdownRowView(categorySpending: categorySpending)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            }
        }
        .background(/* same background */)
    }
}
