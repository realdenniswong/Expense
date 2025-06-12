//
//  OverviewViewModel.swift
//  Expense
//
//  Created by Dennis Wong on 12/6/2025.
//

import SwiftUI
import Charts

// MARK: - Filtered Expenses Helper
struct FilteredExpenses {
    let expenses: [Expense]
    let period: TimePeriod
    
    // Current period amounts
    var todayAmount: Int {
        let calendar = Calendar.current
        let now = Date()
        return expenses.filter { expense in
            calendar.isDate(expense.date, equalTo: now, toGranularity: .day)
        }.reduce(0) { $0 + $1.amountInCents }
    }
    
    var thisWeekAmount: Int {
        let calendar = Calendar.current
        let now = Date()
        return expenses.filter { expense in
            calendar.isDate(expense.date, equalTo: now, toGranularity: .weekOfYear)
        }.reduce(0) { $0 + $1.amountInCents }
    }
    
    var thisMonthAmount: Int {
        let calendar = Calendar.current
        let now = Date()
        return expenses.filter { expense in
            calendar.isDate(expense.date, equalTo: now, toGranularity: .month)
        }.reduce(0) { $0 + $1.amountInCents }
    }
    
    // Filtered expenses based on selected period
    var filteredExpenses: [Expense] {
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case .daily:
            return expenses.filter { expense in
                calendar.isDate(expense.date, equalTo: now, toGranularity: .day)
            }
        case .weekly:
            return expenses.filter { expense in
                calendar.isDate(expense.date, equalTo: now, toGranularity: .weekOfYear)
            }
        case .monthly:
            return expenses.filter { expense in
                calendar.isDate(expense.date, equalTo: now, toGranularity: .month)
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
}
