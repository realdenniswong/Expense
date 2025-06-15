//
//  ExpenseView.swift
//  Expense
//
//  Created by Dennis Wong on 5/6/2025.
//

import SwiftUI

struct ExpenseView: View {
    let transactions: [Transaction]
    let settings: Settings
    @State private var showingAddExpense = false
    @State private var showingQuickEntry = false  // Separate state for accountant mode
    @State private var editingTransaction: Transaction? = nil

    var body: some View {
        NavigationStack {
            if transactions.isEmpty {
                EmptyStateView()
            } else {
                TransactionList(
                    groupedTransactions: groupedTransactions(for: transactions),
                    editingTransaction: $editingTransaction
                )
            }
        }
        .background(Color(.systemGroupedBackground))
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button(action: {
                        showingAddExpense = true  // Normal mode
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                    
                    Button(action: {
                        showingQuickEntry = true  // Accountant mode
                    }) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 18))
                            .fontWeight(.medium)
                    }
                }.padding(.horizontal, 8)
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(accountantMode: false)  // Normal mode
        }
        .sheet(isPresented: $showingQuickEntry) {
            AddExpenseView(accountantMode: true)   // Accountant mode
        }
        .sheet(item: $editingTransaction) { transaction in
            AddExpenseView(transactionToEdit: transaction, accountantMode: false)  // Never accountant mode when editing
        }
    }
    
    func groupedTransactions(for transactions: [Transaction]) -> [(String, [Transaction])] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let grouped = Dictionary(grouping: transactions) { transaction in
            dateFormatter.string(from: transaction.date)
        }
        
        return grouped.sorted { first, second in
            let firstDate = transactions.first { dateFormatter.string(from: $0.date) == first.key }?.date ?? Date.distantPast
            let secondDate = transactions.first { dateFormatter.string(from: $0.date) == second.key }?.date ?? Date.distantPast
            return firstDate > secondDate
        }
    }
}
