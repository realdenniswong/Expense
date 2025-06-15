//
//  CategoryAnalysisView.swift
//  Expense
//
//  Created by Dennis Wong on 12/6/2025.
//
import SwiftUI
import Charts

import SwiftUI
import Charts

struct CategoryAnalysisView: View {
    let transactionAnalyzer: TransactionAnalyzer
    
    var body: some View {
        let categorySpendingTotals = transactionAnalyzer.categorySpendingTotals
        
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Categories")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                Text(transactionAnalyzer.periodDisplayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
            }

            // Chart
            CategoryChartView(
                categorySpendingTotals: categorySpendingTotals,
                period: transactionAnalyzer.period
            )
            
            // Breakdown section
            if !categorySpendingTotals.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    LazyVStack(spacing: 12) {
                        ForEach(categorySpendingTotals, id: \.category.rawValue) { categorySpending in
                            CategoryBreakdownRow(categorySpending: categorySpending)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            }
        }
        .cardBackground()
    }
}

struct CategoryBreakdownRow: View {
    let categorySpending: CategorySpending
    
    var body: some View {
        HStack {
            CategoryIcon(category: categorySpending.category)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(categorySpending.category.rawValue)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text("\(categorySpending.percentage)% of total")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Use Money type directly instead of deprecated Int extension
            Text(Money(cents: categorySpending.amountInCent).formatted)
                .font(.headline)
                .fontWeight(.semibold)
                .monospacedDigit()
        }
        .padding(.vertical, 4)
    }
}
