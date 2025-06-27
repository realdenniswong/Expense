//
//  ExpenseAnalyzer.swift
//  Expense
//
//  Created by Dennis Wong on 12/6/2025.
//

import SwiftUI

struct TransactionAnalyzer {
    let transactions: [Transaction]
    let period: TimePeriod
    let selectedDate: Date
    let settings: Settings?
    
    var todayAmount: Money {
        let calendar = Calendar.current
        return transactions.filter { transaction in
            calendar.isDate(transaction.date, equalTo: selectedDate, toGranularity: .day)
        }.reduce(.zero) { $0 + $1.amount }
    }
    
    var thisWeekAmount: Money {
        let calendar = Calendar.current
        return transactions.filter { transaction in
            calendar.isDate(transaction.date, equalTo: selectedDate, toGranularity: .weekOfYear)
        }.reduce(.zero) { $0 + $1.amount }
    }
    
    var thisMonthAmount: Money {
        let calendar = Calendar.current
        return transactions.filter { transaction in
            calendar.isDate(transaction.date, equalTo: selectedDate, toGranularity: .month)
        }.reduce(.zero) { $0 + $1.amount }
    }
    
    // Filtered transactions based on selected period AND selected date
    var filteredTransactions: [Transaction] {
        let calendar = Calendar.current
        
        switch period {
        case .daily:
            return transactions.filter { transaction in
                calendar.isDate(transaction.date, equalTo: selectedDate, toGranularity: .day)
            }
        case .weekly:
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else {
                return []
            }
            return transactions.filter { transaction in
                transaction.date >= weekInterval.start && transaction.date < weekInterval.end
            }
        case .monthly:
            guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate) else {
                return []
            }
            return transactions.filter { transaction in
                transaction.date >= monthInterval.start && transaction.date < monthInterval.end
            }
        }
    }
    
    // Category spending for filtered period - shows ALL categories
    var categorySpendingTotals: [CategorySpending] {
        let categoryTotals = Dictionary(grouping: filteredTransactions, by: { $0.category })
            .mapValues { transactions in
                transactions.reduce(Money.zero) { $0 + $1.amount }.cents
            }
        
        let filteredCategoryTotals = categoryTotals.filter { _, amount in
            amount > 0
        }
        
        let totalAmount = filteredCategoryTotals.values.reduce(0, +)
        
        return filteredCategoryTotals.map { categoryTotal in
            CategorySpending(
                category: categoryTotal.key,
                amountInCent: categoryTotal.value,
                percentage: totalAmount > 0 ?
                    Int(round((Double(categoryTotal.value) / Double(totalAmount)) * 100)) : 0
            )
        }
        .sorted { $0.amountInCent > $1.amountInCent }
    }
    
    // Category spending for filtered period - shows ALL categories
    var paymentMethodSpendingTotals: [PaymentMethodSpending] {
        let paymenyMethodTotals = Dictionary(grouping: filteredTransactions, by: { $0.paymentMethod })
            .mapValues { transactions in
                transactions.reduce(Money.zero) { $0 + $1.amount }.cents
            }
        
        let filteredCategoryTotals = paymenyMethodTotals.filter { _, amount in
            amount > 0
        }
        
        let totalAmount = filteredCategoryTotals.values.reduce(0, +)
        
        return filteredCategoryTotals.map { paymenyMethodTotal in
            PaymentMethodSpending(
                paymentMethod: paymenyMethodTotal.key,
                amountInCent: paymenyMethodTotal.value,
                percentage: totalAmount > 0 ?
                    Int(round((Double(paymenyMethodTotal.value) / Double(totalAmount)) * 100)) : 0
            )
        }
        .sorted { $0.amountInCent > $1.amountInCent }
    }
    
    // Total spending for goals (only enabled categories)
    var totalGoalsSpending: Money {
        if let settings = settings {
            let enabledCategories = Set(settings.enabledCategories(for: period))
            return filteredTransactions
                .filter { enabledCategories.contains($0.category) }
                .reduce(.zero) { $0 + $1.amount }
        } else {
            return filteredTransactions.reduce(.zero) { $0 + $1.amount }
        }
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
    
    // MARK: - Custom Period Amounts
    
    /// Calculates the total amount for a custom day starting at the specified hour.
    func customDayAmount(startHour: Int) -> Money {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        components.hour = startHour
        let startDate = calendar.date(from: components) ?? selectedDate
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? startDate
        return transactions.filter { $0.date >= startDate && $0.date < endDate }
            .reduce(.zero) { $0 + $1.amount }
    }
    
    /// Calculates the total amount for a custom week starting on the specified weekday.
    func customWeekAmount(startDay: Int) -> Money {
        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: selectedDate)
        let daysToSubtract = (currentWeekday - startDay + 7) % 7
        let startDate = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -daysToSubtract, to: selectedDate) ?? selectedDate)
        let endDate = calendar.date(byAdding: .day, value: 7, to: startDate) ?? startDate
        return transactions.filter { $0.date >= startDate && $0.date < endDate }
            .reduce(.zero) { $0 + $1.amount }
    }
    
    /// Calculates the total amount for a custom month with an optional offset and starting on the specified day.
    func customMonthAmount(monthOffset: Int = 0, startDay: Int) -> Money {
        let calendar = Calendar.current
        guard let adjustedDate = calendar.date(byAdding: .month, value: monthOffset, to: selectedDate) else { return .zero }
        let startOfMonth = calendar.monthlySummaryStart(for: adjustedDate, startDay: startDay)
        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth).flatMap { calendar.date(byAdding: .day, value: -1, to: $0) } ?? startOfMonth
        return transactions.filter { $0.date >= startOfMonth && $0.date <= endOfMonth }
            .reduce(.zero) { $0 + $1.amount }
    }
    
    /// Returns transactions filtered by custom daily/weekly/monthly boundaries according to settings. Use this in places where correct user boundaries are required.
    var customFilteredTransactions: [Transaction] {
        let calendar = Calendar.current
        guard let settings = settings else { return filteredTransactions }
        switch period {
        case .daily:
            var components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
            components.hour = settings.dailyStartHour
            let start = calendar.date(from: components) ?? selectedDate
            let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start
            return transactions.filter { $0.date >= start && $0.date < end }
        case .weekly:
            let weekday = settings.weeklyStartDay
            let currentWeekday = calendar.component(.weekday, from: selectedDate)
            let daysToSubtract = (currentWeekday - weekday + 7) % 7
            let start = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -daysToSubtract, to: selectedDate) ?? selectedDate)
            let end = calendar.date(byAdding: .day, value: 7, to: start) ?? start
            return transactions.filter { $0.date >= start && $0.date < end }
        case .monthly:
            let startDay = settings.monthlyStartDay
            let start = calendar.monthlySummaryStart(for: selectedDate, startDay: startDay)
            let end = calendar.date(byAdding: .month, value: 1, to: start).flatMap { calendar.date(byAdding: .day, value: -1, to: $0) } ?? start
            let exclusiveEnd = calendar.date(byAdding: .day, value: 1, to: end) ?? end
            return transactions.filter { $0.date >= start && $0.date < exclusiveEnd }
        }
    }
    
    // Reminder: Use `customFilteredTransactions` for breakdowns, goals, trends, and analytics that should respect user boundaries.
}
