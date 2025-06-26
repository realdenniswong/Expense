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
}
