//
//  TransactionList.swift - Working Fix
//  Expense
//
//  Created by Dennis Wong on 2/6/2025.
//

import SwiftUI

struct TransactionList: View {
    let groupedTransactions: [(String, [Transaction])]
    @Binding var editingTransaction: Transaction?
    @State private var selectedTransaction: Transaction?
    @State private var listId = UUID() // Force list refresh
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        List {
            ForEach(groupedTransactions, id: \.0) { dateString, transactionsForDate in
                Section(header: Text(dateString)) {
                    ForEach(transactionsForDate.sorted(by: { $0.date > $1.date })) { transaction in
                        TransactionRow(
                            transaction: transaction,
                            selectedTransaction: $selectedTransaction,
                            onRowTapped: {
                                // Small delay to ensure swipe actions close before showing sheet
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    selectedTransaction = transaction
                                }
                            }
                        )
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            deleteSwipeButton(for: transaction)
                            editSwipeButton(for: transaction)
                        }
                    }
                }
            }
        }
        .id(listId) // This forces the list to refresh and close swipe actions
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(UIColor.systemGroupedBackground))
        .sheet(item: $selectedTransaction) { transaction in
            TransactionDetailSheet(transaction: transaction)
        }
    }
    
    private func deleteSwipeButton(for transaction: Transaction) -> some View {
        Button(role: .destructive) {
            listId = UUID()
            deleteTransaction(transaction)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
    
    private func editSwipeButton(for transaction: Transaction) -> some View {
        Button {
            listId = UUID()
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
