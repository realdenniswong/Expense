//
//  ExpensesViewModel.swift
//  Expense
//
//  Created by Dennis Wong on 2/6/2025.
//

import SwiftUI

@Observable
class ExpensesViewModel {
    
    // MARK: - Computed Properties
    
    /// Calculates the total amount of all expenses
    func totalExpenses(for expenses: [Expense]) -> Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
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
    
    // MARK: - Date Formatting Utilities
    
    /// Shared date formatter for consistent date formatting
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    /// Formats a date for display in section headers
    func formatDateForSection(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }
    
    // MARK: - Future Helper Methods
    
    /// Gets expenses for a specific category
    func expenses(for category: ExpenseCategory, from expenses: [Expense]) -> [Expense] {
        expenses.filter { $0.category == category }
    }
    
    /// Gets expenses for a specific date range
    func expenses(from startDate: Date, to endDate: Date, from expenses: [Expense]) -> [Expense] {
        expenses.filter { expense in
            expense.date >= startDate && expense.date <= endDate
        }
    }
    
    /// Gets total for a specific category
    func totalExpenses(for category: ExpenseCategory, from expenses: [Expense]) -> Double {
        self.expenses(for: category, from: expenses).reduce(0) { $0 + $1.amount }
    }
}
