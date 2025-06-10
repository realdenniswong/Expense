//
//  SummaryView.swift
//  Expense
//
//  Created by Dennis Wong on 9/6/2025.
//

import SwiftUI
import Charts
import SwiftData

struct OverviewView: View {
    
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    
    private var categoryTotals: [ExpenseCategory: Double] {
        Dictionary(grouping: expenses, by: { $0.category })
            .mapValues { expenses in
                expenses.reduce(0) { $0 + $1.amount }
            }
    }
    
    private var sortedCategoryData: [(category: ExpenseCategory, amount: Double)] {
        categoryTotals.map { (category: $0.key, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
    }
    
    private var totalAmount: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    private var thisMonthAmount: Double {
        let calendar = Calendar.current
        let now = Date()
        return expenses.filter { expense in
            calendar.isDate(expense.date, equalTo: now, toGranularity: .month)
        }.reduce(0) { $0 + $1.amount }
    }
    
    private var lastMonthAmount: Double {
        let calendar = Calendar.current
        let lastMonth = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        return expenses.filter { expense in
            calendar.isDate(expense.date, equalTo: lastMonth, toGranularity: .month)
        }.reduce(0) { $0 + $1.amount }
    }
    
    // Add this computed property for the month name
    private var currentMonthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: Date())
    }
    
    private var lastMonthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        return formatter.string(from: lastMonth)
    }

    // Update monthlyComparison to remove percentage
    private var monthlyComparison: (amount: String, color: Color, symbol: String) {
        if lastMonthAmount == 0 {
            return (amount: "HK$-", color: .secondary, symbol: "—")
        }
        
        let difference = thisMonthAmount - lastMonthAmount
        
        if abs(difference) < 0.01 {
            return (amount: "HK$0", color: .secondary, symbol: "—")
        }
        
        let isIncrease = difference > 0
        let amountText = "\(isIncrease ? "+" : "")HK$\(String(format: "%.0f", difference))"
        let color: Color = isIncrease ? .red : .green
        let symbol = isIncrease ? "▲" : "▼"
        
        return (amount: amountText, color: color, symbol: symbol)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Total Summary Card
                totalSummaryCard
                
                // Chart Section
                if !expenses.isEmpty {
                    chartSection
                    
                    // Category Breakdown List
                    categoryBreakdownList
                } else {
                    emptyStateView
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var totalSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Total Spending (\(currentMonthName))")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(String(format: "HK$%.0f", thisMonthAmount))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 6) {
                    Text("vs \(lastMonthName)") // Invisible spacer to match left side spacing
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Text(monthlyComparison.symbol)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(monthlyComparison.color)
                        
                        Text(monthlyComparison.amount)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(monthlyComparison.color)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
        .padding(.top, 8)
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending by Category")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal, 4)
            
            Chart(sortedCategoryData, id: \.category.rawValue) { element in
                SectorMark(
                    angle: .value("Amount", element.amount)
                )
                .foregroundStyle(element.category.color)
            }
            .frame(height: 280)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
    
    private var categoryBreakdownList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Breakdown")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal, 4)
            
            LazyVStack(spacing: 12) {
                ForEach(sortedCategoryData, id: \.category.rawValue) { data in
                    categoryRowView(category: data.category, amount: data.amount)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
    
    private func categoryRowView(category: ExpenseCategory, amount: Double) -> some View {
        HStack {
            // Category Icon
            ZStack {
                Circle()
                    .fill(category.color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                category.icon
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(category.color)
            }
            
            // Category Details
            VStack(alignment: .leading, spacing: 2) {
                Text(category.rawValue)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text("\(Int((amount / totalAmount) * 100))% of total")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Amount
            Text(String(format: "HK$%.2f", amount))
                .font(.body)
                .fontWeight(.semibold)
                .monospacedDigit()
        }
        .padding(.vertical, 4)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.pie")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Data to Analyze")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Add some expenses to see your spending breakdown")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.vertical, 60)
    }
}
