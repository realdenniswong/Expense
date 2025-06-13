//
//  TransactionRowView.swift
//  Expense
//
//  Created by Dennis Wong on 2/6/2025.
//

import SwiftUI

struct TransactionRowView: View {
    let expense: Expense
    @Environment(\.editMode) private var editMode
    
    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing == true
    }
    
    var body: some View {
        HStack {
            // Category Icon
            ZStack {
                Circle()
                    .fill(expense.category.color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                expense.category.icon
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(expense.category.color)
            }
            .padding(.trailing, 8) // Adds spacing after the icon
            
            // Expense Details
            VStack(alignment: .leading, spacing: 4) {
                
                Text(expense.expenseDescription)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 4) {
                        Text(expense.category.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(expense.method.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Text(expense.date.timeString)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Amount and Date
            VStack(alignment: .trailing, spacing: 4) {
                Text(expense.amountInCents.currencyString(symbol: "HK$"))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .monospacedDigit()
            }
        }
        // Add extra leading padding when in edit mode to give space for the drag handle
        .padding(.trailing, isEditing ? 10 : 0)
        .animation(.easeInOut(duration: 0.2), value: isEditing)
    }
}
