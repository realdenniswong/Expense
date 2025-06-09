//
//  ExpenseView.swift
//  Expense
//
//  Created by Dennis Wong on 5/6/2025.
//

import SwiftUI
import SwiftData

struct ExpensesView: View {
    
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ExpensesViewModel()
    @State private var showingAddExpense = false
    @State private var editingExpense: Expense? = nil
    

    var body: some View {
        NavigationStack {
            if expenses.isEmpty {
                EmptyStateView()
            } else {
                VStack {
                    TotalExpensesView(totalExpenses: viewModel.totalExpenses(for: expenses))
                    TransactionListView(groupedExpenses: viewModel.groupedExpenses(for: expenses), editingExpense: $editingExpense)
                }
                .padding(.bottom, 50) // padding to avoid overlap with footer
            }
        }
        .background(Color(.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                addExpenseButton
            }
        }
        // When creating a transaction
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView()
        }
        // When editing a transaction
        .sheet(item: $editingExpense) { expense in
            AddExpenseView(expenseToEdit: expense)
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
