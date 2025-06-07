//
//  ReorderableExpenseListView.swift
//  Expense
//
//  Created by Dennis Wong on 2/6/2025.
//

import SwiftUI

struct ReorderableExpenseListView: View {
    @State private var expenses: [Expense] = dummyExpenses
    
    var body: some View {
        NavigationView {
            List {
                ForEach(expenses) { expense in
                    ExpenseRowView(expense: expense)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .padding(.vertical, 4)
                }
                .onMove(perform: moveExpenses)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Expenses")
            .toolbar {
                EditButton()
            }
        }
    }
    
    private func moveExpenses(from source: IndexSet, to destination: Int) {
        expenses.move(fromOffsets: source, toOffset: destination)
        
        // Update the order property to maintain consistency
        for (index, expense) in expenses.enumerated() {
            expenses[index].order = index
        }
    }
}

// Sample data for testing
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
        date: Date().addingTimeInterval(-345600),
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
