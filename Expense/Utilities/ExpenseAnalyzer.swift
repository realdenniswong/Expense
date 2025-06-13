//
//  ExpenseAnalyzer.swift
//  Expense
//
//  Created by Dennis Wong on 12/6/2025.
//

import SwiftUI

// MARK: - Expense Analyzer Helper
struct ExpenseAnalyzer {
    let expenses: [Expense]
    let period: TimePeriod
    let selectedDate: Date
    
    // Filtered expenses based on selected period AND selected date
    var filteredExpenses: [Expense] {
        let calendar = Calendar.current
        
        switch period {
        case .daily:
            return expenses.filter { expense in
                calendar.isDate(expense.date, equalTo: selectedDate, toGranularity: .day)
            }
        case .weekly:
            // Get the week containing the selected date
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else {
                return []
            }
            return expenses.filter { expense in
                expense.date >= weekInterval.start && expense.date < weekInterval.end
            }
        case .monthly:
            // Get the month containing the selected date
            guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate) else {
                return []
            }
            return expenses.filter { expense in
                expense.date >= monthInterval.start && expense.date < monthInterval.end
            }
        }
    }
    
    // Category spending for filtered period
    var categorySpendingTotals: [CategorySpending] {
        let categoryTotals = Dictionary(grouping: filteredExpenses, by: { $0.category })
            .mapValues { expenses in
                expenses.reduce(0) { $0 + $1.amountInCents }
            }
        
        let totalAmount = categoryTotals.values.reduce(0, +)
        
        return categoryTotals.map { categoryTotal in
            CategorySpending(
                category: categoryTotal.key,
                amountInCent: categoryTotal.value,
                percentage: totalAmount > 0 ?
                    Int(round((Double(categoryTotal.value) / Double(totalAmount)) * 100)) : 0
            )
        }
        .sorted { $0.amountInCent > $1.amountInCent }
    }
    
    // Total spending for the selected period
    var totalSpending: Int {
        filteredExpenses.reduce(0) { $0 + $1.amountInCents }
    }
    
    // MARK: - Display Names
    var dailyDisplayName: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: selectedDate)
    }
    
    var weeklyDisplayName: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        formatter.dateFormat = "MMM d"
        if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) {
            let startStr = formatter.string(from: weekInterval.start)
            let endDate = calendar.date(byAdding: .day, value: -1, to: weekInterval.end) ?? weekInterval.end
            let endStr = formatter.string(from: endDate)
            return "\(startStr) - \(endStr)"
        }
        return "Week"
    }
    
    var monthlyDisplayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    var periodDisplayName: String {
        switch period {
        case .daily:
            return dailyDisplayName
        case .weekly:
            return weeklyDisplayName
        case .monthly:
            return monthlyDisplayName
        }
    }
}
