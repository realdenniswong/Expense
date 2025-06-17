//
//  ReorderableExpenseListView.swift
//  Expense
//
//  Created by Dennis Wong on 2/6/2025.
//

import SwiftUI

struct TransactionList: View {
    let groupedTransactions: [(String, [Transaction])]
    @Binding var editingTransaction: Transaction?
    @State private var selectedTransaction: Transaction?
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        List {
            ForEach(groupedTransactions, id: \.0) { dateString, transactionsForDate in
                Section(header: Text(dateString)) {
                    ForEach(transactionsForDate.sorted(by: { $0.date > $1.date })) { transaction in
                        TransactionRow(
                            transaction: transaction,
                            selectedTransaction: $selectedTransaction
                        )
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            deleteSwipeButton(for: transaction)
                            editSwipeButton(for: transaction)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(UIColor.systemGroupedBackground))
        .sheet(item: $selectedTransaction) { transaction in
            TransactionDetailSheet(transaction: transaction)
        }
    }
    
    private func deleteSwipeButton(for transaction: Transaction) -> some View {
        Button(role: .destructive) {
            deleteTransaction(transaction)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
    
    private func editSwipeButton(for transaction: Transaction) -> some View {
        Button {
            editingTransaction = transaction
        } label: {
            Label("Edit", systemImage: "pencil")
        }
        .tint(.blue)
    }
    
    private func deleteTransaction(_ transaction: Transaction) {
        modelContext.delete(transaction)
        try? modelContext.save()
    }
}
