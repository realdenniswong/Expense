//
//  SpendingBreakdownRow.swift
//  Expense
//
//  Created by Dennis Wong on 11/6/2025.
//
import SwiftUI

struct SpendingBreakdownRowView : View {
    
    let categorySpending: CategorySpending
    let expenseCategory: ExpenseCategory
    
    init(categorySpending: CategorySpending) {
        self.categorySpending = categorySpending
        expenseCategory = categorySpending.category
    }
    
    var body: some View {
        HStack {
            // Category Icon
            ZStack {
                Circle()
                    .fill(categorySpending.category.color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                expenseCategory.icon
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(expenseCategory.color)
            }
            
            // Category Details
            VStack(alignment: .leading, spacing: 2) {
                Text(expenseCategory.rawValue)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text("\(categorySpending.formattedPercentage)% of total")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Amount
            Text(String(format: "HK$%.2f", categorySpending.amount))
                .font(.body)
                .fontWeight(.semibold)
                .monospacedDigit()
        }
        .padding(.vertical, 4)
    }
}
