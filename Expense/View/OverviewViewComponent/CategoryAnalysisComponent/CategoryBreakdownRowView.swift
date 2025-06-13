//
//  SpendingBreakdownRow.swift
//  Expense
//
//  Created by Dennis Wong on 11/6/2025.
//
import SwiftUI

struct CategoryBreakdownRowView : View {
    
    let categorySpending: CategorySpending
    let expenseCategory: ExpenseCategory
    
    init(categorySpending: CategorySpending) {
        self.categorySpending = categorySpending
        expenseCategory = categorySpending.category
    }
    
    var body: some View {
        HStack {
            // Category Icon
            CategoryIconView(category: categorySpending.category)
            
            // Category Details
            VStack(alignment: .leading, spacing: 2) {
                Text(expenseCategory.rawValue)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text("\(categorySpending.percentage)% of total")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Amount
            Text(categorySpending.amountInCent.currencyString(symbol: "HK$"))
                .font(.body)
                .fontWeight(.semibold)
                .monospacedDigit()
        }
        .padding(.vertical, 4)
    }
}
