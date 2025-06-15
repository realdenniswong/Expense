//
//  TransactionRowView.swift
//  Expense
//
//  Created by Dennis Wong on 2/6/2025.
//

import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    @Environment(\.editMode) private var editMode
    
    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing == true
    }
    
    var body: some View {
        HStack {
            CategoryIcon(category: transaction.category, size: 48, iconSize: 18)
                .padding(.trailing, 8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 4) {
                        Text(transaction.category.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(transaction.paymentMethod.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Text(transaction.date.timeString)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Use AmountDisplayView instead of direct Text
            AmountDisplayView.medium(transaction.amount)
        }
        .padding(.trailing, isEditing ? 10 : 0)
        .animation(.easeInOut(duration: 0.2), value: isEditing)
    }
}
