//
//  SpendingSummaryView.swift
//  Expense
//
//  Created by Dennis Wong on 11/6/2025.
//
import SwiftUI

struct SpendingSummaryView:  View {
    
    let expenses: [Expense]
    
    init(expenses: [Expense]) {
        self.expenses = expenses
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
    
    private var thisMonthAmount: Int {
        let calendar = Calendar.current
        let now = Date()
        return expenses.filter { expense in
            calendar.isDate(expense.date, equalTo: now, toGranularity: .month)
        }.reduce(0) { $0 + $1.amountInCents }
    }
    
    private var lastMonthAmount: Int {
        let calendar = Calendar.current
        let lastMonth = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        return expenses.filter { expense in
            calendar.isDate(expense.date, equalTo: lastMonth, toGranularity: .month)
        }.reduce(0) { $0 + $1.amountInCents }
    }
    
    // Update monthlyComparison to remove percentage
    private var monthlyComparison: (amount: String, color: Color, symbol: String) {
        if lastMonthAmount == 0 {
            return (amount: "HK$-", color: .secondary, symbol: " ")
        }
        
        let difference = thisMonthAmount - lastMonthAmount
        
        if abs(difference) < 1 {
            return (amount: "HK$0", color: .secondary, symbol: "—")
        }
        
        let isIncrease = difference > 0
        let amountText = "\(isIncrease ? "+" : "")HK$\(String(format: "%.0f", difference))"
        let color: Color = isIncrease ? .red : .green
        let symbol = isIncrease ? "▲" : "▼"
        
        return (amount: amountText, color: color, symbol: symbol)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Total Spending (\(currentMonthName))")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(thisMonthAmount.currencyString(symbol: "HK$"))
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
}
