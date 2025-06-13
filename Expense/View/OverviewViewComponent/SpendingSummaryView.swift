//
//  SpendingSummaryView.swift
//  Expense
//
//  Created by Dennis Wong on 11/6/2025.
//
import SwiftUI

struct SpendingSummaryView: View {
    
    let expenseAnalyzer: ExpenseAnalyzer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending Summary")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(expenseAnalyzer.dailyDisplayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(expenseAnalyzer.todayAmount.currencyString)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .monospacedDigit()
            }
            
            Divider()
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(expenseAnalyzer.weeklyDisplayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(expenseAnalyzer.thisWeekAmount.currencyString)
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
                    
                    Text(expenseAnalyzer.thisMonthAmount.currencyString)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .monospacedDigit()
                }
            }
        }
        .cardBackground()
        .padding(.top, 8)
    }
}
