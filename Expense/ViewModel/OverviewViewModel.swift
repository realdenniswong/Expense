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
    let selectedDate: Date // 新加嘅parameter
    
    // Current period amounts (always based on TODAY for summary)
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
    
    // Helper computed properties for selected period
    var selectedPeriodAmount: Int {
        filteredExpenses.reduce(0) { $0 + $1.amountInCents }
    }
    
    var dailyDisplayName: String {
        
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
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
