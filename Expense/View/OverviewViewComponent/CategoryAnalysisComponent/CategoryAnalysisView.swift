//
//  CategoryAnalysisView.swift
//  Expense
//
//  Created by Dennis Wong on 12/6/2025.
//
import SwiftUI
import Charts

struct CategoryAnalysisView: View {
    let expenseAnalyzer: ExpenseAnalyzer
    
    var body: some View {
        let categorySpendingTotals = expenseAnalyzer.categorySpendingTotals
        
        VStack(alignment: .leading, spacing: 20) {
            
            
            VStack(alignment: .leading, spacing: 4) {
                // Title with dynamic period name
                Text("Categories")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                Text(expenseAnalyzer.periodDisplayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
            }

            
            // Chart (extracted)
            CategoryChartView(
                categorySpendingTotals: categorySpendingTotals,
                period: expenseAnalyzer.period
            )
            
            // Breakdown section (only if has data)
            if !categorySpendingTotals.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    
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
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
}
