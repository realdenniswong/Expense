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
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Delete", role: .destructive) {
                        showingDeleteAlert = true
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditSheet = true
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showingEditSheet) {
            AddExpenseView(transactionToEdit: transaction)
        }
        .alert("Delete Transaction", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteTransaction()
            }
        } message: {
            Text("Are you sure you want to delete this transaction? This action cannot be undone.")
        }
    }
    
    private func deleteTransaction() {
        modelContext.delete(transaction)
        try? modelContext.save()
        dismiss()
    }
}

// Extension to make text selectable
extension Text {
    func selectable() -> some View {
        self.textSelection(.enabled)
    }
}
