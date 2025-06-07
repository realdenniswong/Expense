//
//  ExpenseRowView.swift
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
                    .frame(width: 44, height: 44)
                
                Image(systemName: expense.category.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(expense.category.color)
            }
            .padding(.trailing, 8) // Adds spacing after the icon
            
            // Expense Details
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.description)
                    .font(.body)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text(expense.category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            // Amount and Date
            VStack(alignment: .trailing, spacing: 4) {
                Text(expense.formattedAmount)
                    .font(.body)
                    .fontWeight(.bold)
                
                Text(expense.formattedDate)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        // Add extra leading padding when in edit mode to give space for the drag handle
        .padding(.trailing, isEditing ? 10 : 0)
        .animation(.easeInOut(duration: 0.2), value: isEditing)
    }
}
