//
//  SpendingSummaryView.swift
//  Expense
//
//  Created by Dennis Wong on 11/6/2025.
//
import SwiftUI

struct SpendingSummaryView:  View {
    
    let expenseAnalyzer: ExpenseAnalyzer
    
    // Move the calculations directly into this view
    private var todayAmount: Int {
        let calendar = Calendar.current
        return expenseAnalyzer.expenses.filter { expense in
            calendar.isDate(expense.date, equalTo: expenseAnalyzer.selectedDate, toGranularity: .day)
        }.reduce(0) { $0 + $1.amountInCents }
    }
    
    private var thisWeekAmount: Int {
        let calendar = Calendar.current
        return expenseAnalyzer.expenses.filter { expense in
            calendar.isDate(expense.date, equalTo: expenseAnalyzer.selectedDate, toGranularity: .weekOfYear)
        }.reduce(0) { $0 + $1.amountInCents }
    }
    
    private var thisMonthAmount: Int {
        let calendar = Calendar.current
        return expenseAnalyzer.expenses.filter { expense in
            calendar.isDate(expense.date, equalTo: expenseAnalyzer.selectedDate, toGranularity: .month)
        }.reduce(0) { $0 + $1.amountInCents }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending Summary")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Today's spending (always shown)
            VStack(alignment: .leading, spacing: 6) {
                Text(expenseAnalyzer.dailyDisplayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(todayAmount.currencyString(symbol: "HK$"))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .monospacedDigit()
            }
            
            Divider()
            
            // This week and month
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(expenseAnalyzer.weeklyDisplayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(thisWeekAmount.currencyString(symbol: "HK$"))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .monospacedDigit()
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 6) {
                    Text(expenseAnalyzer.monthlyDisplayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(thisMonthAmount.currencyString(symbol: "HK$"))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .monospacedDigit()
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .padding(.top, 8)
    }
}
