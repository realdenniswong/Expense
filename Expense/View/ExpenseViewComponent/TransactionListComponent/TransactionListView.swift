//
//  ReorderableExpenseListView.swift
//  Expense
//
//  Created by Dennis Wong on 2/6/2025.
//

import SwiftUI

struct TransactionListView: View {
    let groupedExpenses: [(String, [Expense])]
    @Binding var editingExpense: Expense?
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        List {
            ForEach(groupedExpenses, id: \.0) { dateString, expensesForDate in
                Section(header: Text(dateString).listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 8, trailing: 0))) {
                    ForEach(expensesForDate.sorted(by: { $0.date > $1.date })) { expense in
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
            deleteExpense(expense)
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
    
    private func deleteExpense(_ expense: Expense) {
        modelContext.delete(expense)
        
        // Save the context (optional - SwiftData auto-saves, but this ensures immediate persistence)
        try? modelContext.save()
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
