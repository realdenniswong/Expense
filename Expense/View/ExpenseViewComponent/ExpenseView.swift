//
//  ExpenseView.swift
//  Expense
//
//  Created by Dennis Wong on 5/6/2025.
//

import SwiftUI

struct ExpenseView: View {
    
    let expenses: [Expense]
    let settings: Settings
    @State private var showingAddExpense = false
    @State private var editingExpense: Expense? = nil

    // MARK: - View
    
    var body: some View {
        NavigationStack {
            if expenses.isEmpty {
                EmptyStateView()
            } else {
                ExpenseListView(groupedExpenses: groupedExpenses(for: expenses), editingExpense: $editingExpense)
            }
        }
        .background(Color(.systemGroupedBackground))
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                HStack(spacing: 16){
                    
                    Button(action: {
                        showingAddExpense = true
                        settings.accountantMode = false;
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                    
                    Button(action: {
                        showingAddExpense = true
                        settings.accountantMode = true;
                    }) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 18))
                            .fontWeight(.medium)
                    }
                }.padding(.horizontal, 8)
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
    // MARK: - Functions
    
    /// Groups expenses by date and sorts them (most recent first)
    func groupedExpenses(for expenses: [Expense]) -> [(String, [Expense])] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let grouped = Dictionary(grouping: expenses) { expense in
            dateFormatter.string(from: expense.date)
        }
        
        // Sort by date (most recent first)
        return grouped.sorted { first, second in
            let firstDate = expenses.first { dateFormatter.string(from: $0.date) == first.key }?.date ?? Date.distantPast
            let secondDate = expenses.first { dateFormatter.string(from: $0.date) == second.key }?.date ?? Date.distantPast
            return firstDate > secondDate
        }
    }
}
