//
//  ReorderableExpenseListView.swift
//  Expense
//
//  Created by Dennis Wong on 2/6/2025.
//

import SwiftUI

struct TransactionListView: View {
    @State private var expenses: [Expense] = dummyExpenses
    @Environment(\.editMode) private var editMode
    
    // Group expenses by date
    private var groupedExpenses: [(String, [Expense])] {
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
    
    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing == true
    }
    
    var body: some View {
        List {
            ForEach(groupedExpenses, id: \.0) { dateString, expensesForDate in
                Section(header: Text(dateString)) {
                    ForEach(expensesForDate) { expense in
                        TransactionRowView(expense: expense)
                    }
                    .onMove(perform: isEditing ? { source, destination in
                        moveExpenses(in: dateString, from: source, to: destination)
                    } : nil)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    private func moveExpenses(in dateString: String, from source: IndexSet, to destination: Int) {
        // Find the expenses for this date
        guard let sectionIndex = groupedExpenses.firstIndex(where: { $0.0 == dateString }) else { return }
        
        var expensesForDate = groupedExpenses[sectionIndex].1
        expensesForDate.move(fromOffsets: source, toOffset: destination)
        
        // Update the main expenses array
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        // Remove old expenses for this date
        expenses.removeAll { expense in
            dateFormatter.string(from: expense.date) == dateString
        }
        
        // Add back the reordered expenses
        expenses.append(contentsOf: expensesForDate)
        
        // Update order property for consistency
        for (index, _) in expenses.enumerated() {
            expenses[index].order = index
        }
        
        // Sort expenses to maintain date grouping
        expenses.sort { $0.date > $1.date }
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
