//
//  ReorderableExpenseListView.swift
//  Expense
//
//  Created by Dennis Wong on 2/6/2025.
//

import SwiftUI

struct TransactionListView: View {
    //@State private var expenses: [Expense] = dummyExpenses
    @ObservedObject var expenseManager: ExpenseManager
    var expenses: [Expense] = []
    
    @Binding var editingExpense: Expense?
    
    init(expenseManager: ExpenseManager, editingExpense: Binding<Expense?>) {
        self.expenseManager = expenseManager
        expenses = expenseManager.expenses
        self._editingExpense = editingExpense
    }
    
    var body: some View {
        List {
            ForEach(expenseManager.groupedExpenses, id: \.0) { dateString, expensesForDate in
                Section(header: Text(dateString)) {
                    ForEach(expensesForDate) { expense in
                        TransactionRowView(expense: expense)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                deleteSwipeButton(for: expense)
                                editSwipeButton(for: expense)
                            }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    private func deleteSwipeButton(for expense: Expense) -> some View {
        Button(role: .destructive) {
            expenseManager.deleteExpenses(expense)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
    
    private func editSwipeButton(for expense: Expense) -> some View {
        Button {
            editingExpense = expense
        } label: {
            Label("Edit", systemImage: "pencil")
        }
        .tint(.blue)
    }
    
}

// Sample data for testing
/*
private let dummyExpenses: [Expense] = [
    Expense(
        id: UUID(),
        description: "Grocery Shopping",
        amount: 85.32,
        category: .foodDrink,
        date: Date(),
        order: 0
    ),
    Expense(
        id: UUID(),
        description: "Gas Station",
        amount: 45.67,
        category: .transportation,
        date: Date().addingTimeInterval(-86400),
        order: 1
    ),
    Expense(
        id: UUID(),
        description: "Netflix Subscription",
        amount: 15.99,
        category: .entertainment,
        date: Date().addingTimeInterval(-172800),
        order: 2
    ),
    Expense(
        id: UUID(),
        description: "Electric Bill",
        amount: 120.45,
        category: .billsUtilities,
        date: Date().addingTimeInterval(-259200),
        order: 3
    ),
    Expense(
        id: UUID(),
        description: "Coffee Shop",
        amount: 6.75,
        category: .foodDrink,
        date: Date().addingTimeInterval(-432000),
        order: 4
    ),
    Expense(
        id: UUID(),
        description: "Online Shopping",
        amount: 89.99,
        category: .shopping,
        date: Date().addingTimeInterval(-432000),
        order: 5
    )
]
*/
