//
//  SpendingSummaryView.swift
//  Expense
//
//  Created by Dennis Wong on 11/6/2025.
//
import SwiftUI

struct SpendingSummaryView:  View {
    let filteredExpenses: FilteredExpenses
        
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending Summary")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Today's spending (always shown)
            VStack(alignment: .leading, spacing: 6) {
                Text("Today")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(filteredExpenses.todayAmount.currencyString(symbol: "HK$"))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .monospacedDigit()
            }
            
            Divider()
            
            // This week and month
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("This Week")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(filteredExpenses.thisWeekAmount.currencyString(symbol: "HK$"))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .monospacedDigit()
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 6) {
                    Text("This Month")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(filteredExpenses.thisMonthAmount.currencyString(symbol: "HK$"))
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
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
        .padding(.top, 8)
    }
}
