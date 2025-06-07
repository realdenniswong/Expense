//
//  ExpenseView.swift
//  Expense
//
//  Created by Dennis Wong on 5/6/2025.
//

import SwiftUI

struct ExpensesView: View {
    @StateObject private var expenseManager = ExpenseManager()
    @State private var showingAddExpense = false
    @State private var editingExpense: Expense? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                TotalExpensesView(totalExpenses: expenseManager.totalExpenses)
                TransactionListView(expenseManager: self.expenseManager, editingExpense: $editingExpense)
            }
            .padding(.bottom, 50) // padding to avoid overlap with footer
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    addExpenseButton
                }
            }
            // When creating a transaction
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView(expenseManager: expenseManager)
            }
            // When editing a transaction
            .sheet(item: $editingExpense) { expense in
                AddExpenseView(expenseManager: expenseManager, expenseToEdit: expense)
            }
        }
    }
    
    private var addExpenseButton: some View {
        Button(action: {
            showingAddExpense = true
        }) {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.medium)
        }
    }
}
