//
//  TransactionDetailSheet.swift
//  Expense
//
//  Created by Dennis Wong on 18/6/2025.
//

import SwiftUI

struct TransactionDetailSheet: View {
    let transaction: Transaction
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            CategoryIcon(category: transaction.category, size: 60, iconSize: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(transaction.category.rawValue)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text(transaction.paymentMethod.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            AmountDisplayView.large(transaction.amount)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Description")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                            
                            Text(transaction.title)
                                .font(.body)
                                .selectable()
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    HStack {
                        Text("Date")
                        Spacer()
                        Text(transaction.date.dateString + " " + transaction.date.timeString)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.top, -20)
            .navigationTitle("Transaction Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

// Extension to make text selectable
extension Text {
    func selectable() -> some View {
        self.textSelection(.enabled)
    }
}
